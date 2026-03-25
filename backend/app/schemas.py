from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, TYPE_CHECKING
from datetime import datetime
from .models import Status, QuestionType

if TYPE_CHECKING:
    pass

class UserBase(BaseModel):
    name: str = Field(..., alias="username")
    status: Status = Field(default=Status.student, alias="role")

    model_config = {
        "populate_by_name": True,
        "by_alias": True,  # Use aliases when serializing to JSON
    }

class UserCreate(UserBase):
    password: str
    
    @field_validator('status', mode='before')
    @classmethod
    def validate_status(cls, v):
        """Convert role string to Status enum."""
        if v is None:
            return Status.student
        if isinstance(v, Status):
            return v
        if isinstance(v, str):
            v_lower = v.lower()
            for status in Status:
                if status.value == v_lower or status.name == v_lower:
                    return status
            return Status.student  # Default fallback
        return v

class User(UserBase):
    id: int

    class Config:
        from_attributes = True
        populate_by_name = True
        by_alias = True  # Use aliases when serializing

class UserInDB(User):
    hashed_password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# Test schemas
class TestBase(BaseModel):
    name: str
    description: Optional[str] = None

class TestCreate(TestBase):
    pass

class Test(TestBase):
    id: int
    access_code: str
    teacher_id: int

    class Config:
        from_attributes = True

class TestWithQuestions(Test):
    questions: List["QuestionWithAnswers"] = []

# Test response for students (with student questions and answers)
class TestResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    access_code: str
    questions: List["QuestionStudent"] = []

    class Config:
        from_attributes = True

# Question schemas
class QuestionBase(BaseModel):
    text: str
    type: QuestionType
    question_order: int

class QuestionCreate(QuestionBase):
    pass

class QuestionCreateWithAnswers(QuestionBase):
    answers: List["AnswerCreate"]

    @field_validator('answers')
    @classmethod
    def validate_answers(cls, v):
        if not v:
            raise ValueError('Question must have at least one answer')
        correct_count = sum(1 for a in v if a.is_correct)
        if correct_count == 0:
            raise ValueError('At least one answer must be marked as correct')
        return v

class Question(QuestionBase):
    id: int
    test_id: int

    class Config:
        from_attributes = True

class QuestionWithAnswers(Question):
    answers: List["Answer"] = []

# Question for students (with answers without is_correct)
class QuestionStudent(QuestionBase):
    id: int
    question_order: int
    answers: List["AnswerStudent"] = []

    class Config:
        from_attributes = True

# Answer schemas
class AnswerBase(BaseModel):
    text: str
    is_correct: bool

class AnswerCreate(AnswerBase):
    pass

class Answer(AnswerBase):
    id: int
    question_id: int

    class Config:
        from_attributes = True

# Answer for students (without is_correct)
class AnswerStudent(BaseModel):
    id: int
    text: str

    class Config:
        from_attributes = True

# TestAttempt schemas
class TestAttemptBase(BaseModel):
    pass

class TestAttemptCreate(TestAttemptBase):
    pass

class TestAttempt(TestAttemptBase):
    id: int
    student_id: int
    test_id: int
    started_at: datetime
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class TestAttemptWithAnswers(TestAttempt):
    student_answers: List["StudentAnswer"] = []

# StudentAnswer schemas
class StudentAnswerBase(BaseModel):
    question_id: int
    answer_id: int

class StudentAnswerCreate(StudentAnswerBase):
    pass

class StudentAnswer(StudentAnswerBase):
    id: int
    attempt_id: int

    class Config:
        from_attributes = True

# For student submitting answers
class SubmitAnswers(BaseModel):
    answers: List[StudentAnswerCreate]

# For getting test by access code
class TestAccess(BaseModel):
    access_code: str

# Test Result schema
class TestResult(BaseModel):
    attempt_id: int
    total_questions: int
    correct_answers: int
    score: float  # percentage

# Attempt Result (for listing teacher's test results)
class AttemptResult(BaseModel):
    attempt_id: int
    student_id: int
    student_name: str
    started_at: datetime
    completed_at: Optional[datetime] = None
    total_questions: int
    correct_answers: int
    score: float

    class Config:
        from_attributes = True

# Update forward references
TestWithQuestions.update_forward_refs()
QuestionWithAnswers.update_forward_refs()
QuestionCreateWithAnswers.update_forward_refs()
TestAttemptWithAnswers.update_forward_refs()
QuestionStudent.update_forward_refs()
TestResponse.update_forward_refs()