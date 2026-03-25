from sqlalchemy import Column, Integer, String, Enum, ForeignKey, DateTime, Boolean, Text
import enum
from sqlalchemy.orm import relationship
from .database import Base

class Status(enum.Enum):
    student = "student"
    teacher = "teacher"
    admin = "admin"

class QuestionType(enum.Enum):
    single = "single"
    multiple = "multiple"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    password = Column(String)
    status = Column(Enum(Status), default=Status.student)

    # Relationships
    created_tests = relationship("Test", back_populates="teacher")
    test_attempts = relationship("TestAttempt", back_populates="student")

class Test(Base):
    __tablename__ = "tests"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    access_code = Column(String, unique=True, nullable=False)
    teacher_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # Relationships
    teacher = relationship("User", back_populates="created_tests")
    questions = relationship("Question", back_populates="test", cascade="all, delete-orphan")
    attempts = relationship("TestAttempt", back_populates="test", cascade="all, delete-orphan")

class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    text = Column(Text, nullable=False)
    type = Column(Enum(QuestionType), nullable=False)
    question_order = Column(Integer, nullable=False)
    test_id = Column(Integer, ForeignKey("tests.id"), nullable=False)

    # Relationships
    test = relationship("Test", back_populates="questions")
    answers = relationship("Answer", back_populates="question", cascade="all, delete-orphan")
    student_answers = relationship("StudentAnswer", back_populates="question")

class Answer(Base):
    __tablename__ = "answers"

    id = Column(Integer, primary_key=True, index=True)
    text = Column(Text, nullable=False)
    is_correct = Column(Boolean, default=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)

    # Relationships
    question = relationship("Question", back_populates="answers")
    student_answers = relationship("StudentAnswer", back_populates="answer")

class TestAttempt(Base):
    __tablename__ = "test_attempts"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    test_id = Column(Integer, ForeignKey("tests.id"), nullable=False)
    started_at = Column(DateTime, nullable=False)
    completed_at = Column(DateTime, nullable=True)

    # Relationships
    student = relationship("User", back_populates="test_attempts")
    test = relationship("Test", back_populates="attempts")
    student_answers = relationship("StudentAnswer", back_populates="attempt", cascade="all, delete-orphan")

class StudentAnswer(Base):
    __tablename__ = "student_answers"

    id = Column(Integer, primary_key=True, index=True)
    attempt_id = Column(Integer, ForeignKey("test_attempts.id"), nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    answer_id = Column(Integer, ForeignKey("answers.id"), nullable=False)

    # Relationships
    attempt = relationship("TestAttempt", back_populates="student_answers")
    question = relationship("Question", back_populates="student_answers")
    answer = relationship("Answer", back_populates="student_answers")