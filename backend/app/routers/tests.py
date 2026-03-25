from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel
from .. import crud, models, schemas
from ..database import get_db
from ..auth import get_current_user
from typing import List

router = APIRouter()

# Teacher endpoints

# Handle both /tests and /tests/ due to redirect_slashes=False
@router.get("", response_model=List[schemas.TestWithQuestions])
@router.get("/", response_model=List[schemas.TestWithQuestions])
def get_my_tests(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get all tests created by the current teacher."""
    if current_user.status != models.Status.teacher:
        raise HTTPException(status_code=403, detail="Only teachers can list tests")
    tests = crud.get_teacher_tests(db, current_user.id)
    return tests

@router.post("", response_model=schemas.Test)
@router.post("/", response_model=schemas.Test)
def create_test(test: schemas.TestCreate, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Create a new test."""
    import logging
    logger = logging.getLogger(__name__)
    
    logger.info(f"[CREATE_TEST_ENDPOINT] Attempting to create test: user_id={current_user.id}, user_name={current_user.name}, user_status={current_user.status}")
    
    if current_user.status != models.Status.teacher:
        logger.warning(f"[CREATE_TEST_ENDPOINT] User is not teacher: user_status={current_user.status}, expected=Status.teacher")
        raise HTTPException(status_code=403, detail="Only teachers can create tests")
    
    logger.info(f"[CREATE_TEST_ENDPOINT] User is teacher, proceeding to create test")
    
    try:
        result = crud.create_test(db, test, current_user.id)
        logger.info(f"[CREATE_TEST_ENDPOINT] Test created successfully: test_id={result.id}")
        return result
    except Exception as e:
        logger.error(f"[CREATE_TEST_ENDPOINT] Error creating test: {str(e)}")
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create test: {str(e)}")

@router.post("/{test_id}/questions", response_model=schemas.QuestionWithAnswers)
def add_question(test_id: int, question: schemas.QuestionCreateWithAnswers, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.status != models.Status.teacher:
        raise HTTPException(status_code=403, detail="Only teachers can add questions")
    test = crud.get_test_with_questions(db, test_id)
    if not test or test.teacher_id != current_user.id:
        raise HTTPException(status_code=404, detail="Test not found or not owned by you")
    return crud.create_question_with_answers(db, question, test_id)

@router.post("/{test_id}/questions/{question_id}/answers", response_model=schemas.Answer)
def add_answer(
    test_id: int,
    question_id: int,
    answer: schemas.AnswerCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.status != models.Status.teacher:
        raise HTTPException(status_code=403, detail="Only teachers can add answers")
    test = crud.get_test_with_questions(db, test_id)
    if not test or test.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your test")
    question = db.query(models.Question).filter(
        models.Question.id == question_id,
        models.Question.test_id == test_id
    ).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    return crud.create_answer(db, answer, question_id)

@router.get("/{test_id}/results", response_model=List[schemas.AttemptResult])
def get_test_results(
    test_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all attempt results for a specific test (only for the teacher who created it)."""
    if current_user.status != models.Status.teacher:
        raise HTTPException(status_code=403, detail="Only teachers can view results")
    
    results = crud.get_test_attempts_with_results(db, test_id, current_user.id)
    if results is None:
        raise HTTPException(status_code=404, detail="Test not found or not owned by you")
    
    return results

@router.get("/access", response_model=schemas.TestResponse)
def get_test_by_access_code(
    access_code: str = Query(...),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.status != models.Status.student:
        raise HTTPException(status_code=403, detail="Only students can access tests")
    test = crud.get_test_by_access_code(db, access_code)
    if not test:
        raise HTTPException(status_code=404, detail="Test not found")
    return test

@router.get("/{test_id}", response_model=schemas.TestResponse)
def get_test_by_id_simple(
    test_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get test by ID."""
    test = crud.get_test_with_questions(db, test_id)
    if not test:
        raise HTTPException(status_code=404, detail="Test not found")
    return test

# Start attempt - accept test_id in request body
class StartAttemptRequest(BaseModel):
    test_id: int

@router.post("/attempts", response_model=schemas.TestAttempt)
@router.post("/attempts/", response_model=schemas.TestAttempt)
def start_attempt(request: StartAttemptRequest, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.status != models.Status.student:
        raise HTTPException(status_code=403, detail="Only students can start attempts")
    test = crud.get_test_with_questions(db, request.test_id)
    if not test:
        raise HTTPException(status_code=404, detail="Test not found")
    return crud.create_test_attempt(db, current_user.id, request.test_id)

@router.post("/attempts/{attempt_id}/answers", response_model=dict)
def submit_answers(attempt_id: int, submit: schemas.SubmitAnswers, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.status != models.Status.student:
        raise HTTPException(status_code=403, detail="Only students can submit answers")
    attempt = crud.get_attempt_by_id(db, attempt_id)
    if not attempt or attempt.student_id != current_user.id:
        raise HTTPException(status_code=404, detail="Attempt not found or not yours")
    crud.create_student_answers(db, attempt_id, submit.answers)
    return {"message": "Answers submitted"}

@router.post("/attempts/{attempt_id}/complete", response_model=schemas.TestResult)
def complete_test(attempt_id: int, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.status != models.Status.student:
        raise HTTPException(status_code=403, detail="Only students can complete tests")
    attempt = crud.get_attempt_by_id(db, attempt_id)
    if not attempt or attempt.student_id != current_user.id:
        raise HTTPException(status_code=404, detail="Attempt not found or not yours")
    result = crud.complete_attempt(db, attempt_id)
    if not result:
        raise HTTPException(status_code=404, detail="Attempt not found")
    result_data = crud.calculate_result(db, attempt_id)
    return result_data