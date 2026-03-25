from sqlalchemy.orm import Session
from . import models, schemas
from datetime import datetime
from typing import List
import logging

logger = logging.getLogger(__name__)

# User CRUD
def get_user_by_name(db: Session, name: str):
    return db.query(models.User).filter(models.User.name == name).first()

def create_user(db: Session, user: schemas.UserCreate):
    from .auth import get_password_hash
    hashed_password = get_password_hash(user.password)
    
    logger.info(f"[CREATE_USER] Creating user: name={user.name}, status={user.status}")
    
    db_user = models.User(name=user.name, password=hashed_password, status=user.status)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    logger.info(f"[CREATE_USER] User created: id={db_user.id}, name={db_user.name}, status={db_user.status}")
    return db_user

# Test CRUD
def get_test_by_access_code(db: Session, access_code: str):
    return db.query(models.Test).filter(models.Test.access_code == access_code).first()

import random
import string


def _generate_access_code(length: int = 8) -> str:
    return "".join(random.choices(string.ascii_uppercase + string.digits, k=length))


def create_test(db: Session, test: schemas.TestCreate, teacher_id: int):
    """Create a new test.
    
    Args:
        db: Database session
        test: Test data to create
        teacher_id: ID of the teacher creating the test
    
    Returns:
        models.Test: Created test object
    """
    # Generate unique access code
    access_code = _generate_access_code()
    while get_test_by_access_code(db, access_code) is not None:
        access_code = _generate_access_code()
    
    logger.info(f"[CREATE_TEST] Creating test: name={test.name}, teacher_id={teacher_id}, access_code={access_code}")
    
    # Create test object
    db_test = models.Test(
        name=test.name,
        description=test.description,
        access_code=access_code,
        teacher_id=teacher_id
    )
    
    # Add and commit to database
    db.add(db_test)
    logger.debug(f"[CREATE_TEST] Test object added to session")
    
    db.flush()  # Ensure ID is generated
    logger.info(f"[CREATE_TEST] Test flushed, ID generated: {db_test.id}")
    
    db.commit()  # Persist to database
    logger.info(f"[CREATE_TEST] Test committed to database: id={db_test.id}")
    
    db.refresh(db_test)  # Reload from database
    logger.info(f"[CREATE_TEST] Test refreshed: id={db_test.id}, name={db_test.name}")
    
    return db_test

def get_test_with_questions(db: Session, test_id: int):
    logger.info(f"[GET_TEST] Fetching test with questions: test_id={test_id}")
    result = db.query(models.Test).filter(models.Test.id == test_id).first()
    if result:
        logger.info(f"[GET_TEST] Found test: id={result.id}, name={result.name}")
    else:
        logger.warning(f"[GET_TEST] Test not found: test_id={test_id}")
    return result

def get_teacher_tests(db: Session, teacher_id: int):
    """Get all tests created by a teacher."""
    return db.query(models.Test).filter(models.Test.teacher_id == teacher_id).all()

def get_test_with_full_data(db: Session, test_id: int):
    """
    Get test with all questions and answers (for students - without is_correct).
    Includes eager loading of related questions and answers.
    """
    test = db.query(models.Test).filter(models.Test.id == test_id).first()
    if not test:
        return None
    
    # Questions are already loaded via relationship, but let's ensure they're sorted
    # Load and sort questions by question_order
    test.questions = sorted(test.questions, key=lambda q: q.question_order)
    
    # Sort answers for each question by id (optional, but for consistency)
    for question in test.questions:
        question.answers = sorted(question.answers, key=lambda a: a.id)
    
    return test

# Question CRUD
def create_question(db: Session, question: schemas.QuestionCreate, test_id: int):
    db_question = models.Question(**question.model_dump(), test_id=test_id)
    db.add(db_question)
    db.commit()
    db.refresh(db_question)
    return db_question

def create_question_with_answers(db: Session, question: schemas.QuestionCreateWithAnswers, test_id: int):
    """Create a question together with its answer options in a single transaction."""
    answers_data = question.answers
    question_data = question.model_dump(exclude={"answers"})
    db_question = models.Question(**question_data, test_id=test_id)
    db.add(db_question)
    db.flush()  # get db_question.id before commit

    for answer in answers_data:
        db_answer = models.Answer(**answer.model_dump(), question_id=db_question.id)
        db.add(db_answer)

    db.commit()
    db.refresh(db_question)
    return db_question

# Answer CRUD
def create_answer(db: Session, answer: schemas.AnswerCreate, question_id: int):
    db_answer = models.Answer(**answer.model_dump(), question_id=question_id)
    db.add(db_answer)
    db.commit()
    db.refresh(db_answer)
    return db_answer

# TestAttempt CRUD
def create_test_attempt(db: Session, student_id: int, test_id: int):
    db_attempt = models.TestAttempt(student_id=student_id, test_id=test_id, started_at=datetime.utcnow())
    db.add(db_attempt)
    db.commit()
    db.refresh(db_attempt)
    return db_attempt

def get_attempt_by_id(db: Session, attempt_id: int):
    return db.query(models.TestAttempt).filter(models.TestAttempt.id == attempt_id).first()

def complete_attempt(db: Session, attempt_id: int):
    attempt = db.query(models.TestAttempt).filter(models.TestAttempt.id == attempt_id).first()
    if attempt:
        attempt.completed_at = datetime.utcnow()
        db.commit()
        db.refresh(attempt)
    return attempt

# StudentAnswer CRUD
def create_student_answers(db: Session, attempt_id: int, answers: List[schemas.StudentAnswerCreate]):
    for answer in answers:
        db_answer = models.StudentAnswer(attempt_id=attempt_id, **answer.model_dump())
        db.add(db_answer)
    db.commit()

def get_student_answers_for_attempt(db: Session, attempt_id: int):
    return db.query(models.StudentAnswer).filter(models.StudentAnswer.attempt_id == attempt_id).all()

# Calculate result
def calculate_result(db: Session, attempt_id: int):
    attempt = get_attempt_by_id(db, attempt_id)
    if not attempt:
        return None
    questions = db.query(models.Question).filter(models.Question.test_id == attempt.test_id).all()
    total_questions = len(questions)
    correct_answers = 0
    for question in questions:
        student_answers = db.query(models.StudentAnswer).filter(
            models.StudentAnswer.attempt_id == attempt_id,
            models.StudentAnswer.question_id == question.id
        ).all()
        selected_answer_ids = {sa.answer_id for sa in student_answers}
        correct_answer_ids = {a.id for a in question.answers if a.is_correct}
        if selected_answer_ids == correct_answer_ids:
            correct_answers += 1
    score = (correct_answers / total_questions) * 100 if total_questions > 0 else 0
    return schemas.TestResult(
        attempt_id=attempt_id,
        total_questions=total_questions,
        correct_answers=correct_answers,
        score=score
    )

def get_test_attempts_with_results(db: Session, test_id: int, teacher_id: int):
    """Get all test attempts for a specific test with calculated results."""
    test = db.query(models.Test).filter(
        models.Test.id == test_id,
        models.Test.teacher_id == teacher_id
    ).first()
    
    if not test:
        return None
    
    attempts = db.query(models.TestAttempt).filter(
        models.TestAttempt.test_id == test_id
    ).all()
    
    results = []
    for attempt in attempts:
        # Only include completed attempts
        if attempt.completed_at:
            result = calculate_result(db, attempt.id)
            student = db.query(models.User).filter(models.User.id == attempt.student_id).first()
            if result and student:
                results.append({
                    "attempt_id": attempt.id,
                    "student_id": attempt.student_id,
                    "student_name": student.name,
                    "started_at": attempt.started_at,
                    "completed_at": attempt.completed_at,
                    "total_questions": result.total_questions,
                    "correct_answers": result.correct_answers,
                    "score": result.score
                })
    
    return results