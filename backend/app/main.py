from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from .database import engine
from . import models
from .routers import users, tests
import logging

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger("api")

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Middleware to log all requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Method: {request.method} | Path: {request.url.path}")
    logger.info(f"Headers: {dict(request.headers)}")
    response = await call_next(request)
    return response

# Translate common error messages to Russian
_error_translations = {
    "Not authenticated": "Не авторизован",
    "Only teachers can create tests": "Только преподаватель может создавать тесты",
    "Only teachers can add questions": "Только преподаватель может добавлять вопросы",
    "Only students can access tests": "Только студент может получить тест",
    "Only students can start attempts": "Только студент может начать попытку",
    "Only students can submit answers": "Только студент может отправить ответы",
    "Only students can complete tests": "Только студент может завершить тест",
    "Test not found": "Тест не найден",
    "Attempt not found or not yours": "Попытка не найдена или она не ваша",
    "Question not found": "Вопрос не найден",
    "Access code already exists": "Код доступа уже существует",
    "Not your test": "Это не ваш тест",
}

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    detail = exc.detail
    if isinstance(detail, str):
        detail = _error_translations.get(detail, detail)
    return JSONResponse(status_code=exc.status_code, content={"detail": detail})

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(users.router, prefix="/users", tags=["users"])
app.include_router(tests.router, prefix="/tests", tags=["tests"])
