# Backend (FastAPI) — Система тестирования

Коротко: бэкенд написан на FastAPI с PostgreSQL, использует SQLAlchemy, авторизацию по JWT и разворачивается через Docker Compose.

Технологии:
- Python 3.8+
- FastAPI
- SQLAlchemy
- PostgreSQL
- Docker / Docker Compose

Содержание этого README:
- Короткое описание
- Быстрый старт (Docker)
- Локальная разработка (venv)
- Переменные окружения
- Основные маршруты API и авторизация
- Полезные команды и отладка

Ресурсы в репозитории:
- Полный список эндпоинтов: [backend/ENDPOINTS.md](ENDPOINTS.md)
- Быстрая подсказка: [backend/QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Быстрый старт (Docker Compose)**

1) Сборка и запуск:

```bash
cd backend
docker-compose up --build -d
```

2) По умолчанию API будет доступно по адресу http://localhost:8000
3) Документация OpenAPI (Swagger UI): http://localhost:8000/docs

Примечание: контейнер с БД определяется в `docker-compose.yml` (Postgres). По умолчанию в compose указаны переменные `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.

**Локальная разработка без Docker**

1) Создайте и активируйте виртуальное окружение:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2) Создайте/настройте переменные окружения (см. раздел ниже).

3) Запустите приложение для разработки:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Переменные окружения**

Рекомендуется задавать в окружении (или в файле `.env`, если используете docker-compose или dotenv).
- `DATABASE_URL` — URL подключения к БД, пример: `postgresql://user:password@db/dbname`. По умолчанию используется значение из `docker-compose.yml`.
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` — используются при поднятии контейнера Postgres в Docker Compose.
- `SECRET_KEY` — строка для подписи JWT; обязательно заменить на надёжную в продакшене (в `app/auth.py` по умолчанию стоит заглушка).
- `ACCESS_TOKEN_EXPIRE_MINUTES` — время жизни access token в минутах (по умолчанию 30 в `app/auth.py`).

Пример (в окружении):

```bash
export DATABASE_URL="postgresql://user:password@localhost/dbname"
export SECRET_KEY="<сильный_случайный_ключ>"
export ACCESS_TOKEN_EXPIRE_MINUTES=60
```

**Авторизация и токены**

Аутентификация реализована через JWT. Точка получения токена — `POST /users/login` (см. [backend/ENDPOINTS.md](ENDPOINTS.md)). Токен передаётся в заголовке `Authorization: Bearer <token>`.

В `app/auth.py`:
- `SECRET_KEY` и `ALGORITHM` используются для подписи токенов.
- Функция `create_access_token(...)` формирует токен с полем `exp`.

Рекомендуется положить `SECRET_KEY` в переменные окружения и не хранить в коде.

**Основные маршруты**

- `POST /users/register` — регистрация пользователя
- `POST /users/login` — получение access token
- Router `users` подключён по префиксу `/users`
- Router `tests` подключён по префиксу `/tests`

Подробные endpoint-спецификации и примеры запросов находятся в [backend/ENDPOINTS.md](ENDPOINTS.md).

Пример curl-входа и получения списка (пример):

```bash
curl -X POST "http://localhost:8000/users/login" -H "Content-Type: application/json" -d '{"name":"teacher1","password":"pass"}'
# ответ содержит access_token
curl -H "Authorization: Bearer <token>" http://localhost:8000/tests
```

**База данных и модели**

Модели описаны в `app/models.py`. В `app/main.py` при старте выполняется `models.Base.metadata.create_all(bind=engine)`, поэтому таблицы создаются автоматически при подключении к БД.

Если вы предпочитаете миграции — добавьте Alembic/Flask-Migrate и интегрируйте с текущей схемой.

**Отладка и логирование**

Логи конфигурируются через стандартный `logging` (см. `app/main.py`). В продакшне настройте уровень логирования и обработчики.

**Полезные команды**

- Поднять сервисы в фоне: `docker-compose up -d --build`
- Остановить и удалить контейнеры: `docker-compose down`
- Просмотреть логи сервиса: `docker-compose logs -f`
- Войти в контейнер приложения: `docker-compose exec backend bash` (если сервис называется `backend` в compose)

**Частые проблемы и советы**

- Если приложение не подключается к БД — проверьте значение `DATABASE_URL` и то, что контейнер postgres запущен и доступен по сети Docker.
- В проде не используйте `allow_origins=["*"]` в CORS; ограничьте список доверенных доменов (см. `app/main.py`).
- Обязательно замените `SECRET_KEY` на безопасный.

**Дальше**

- Добавить систему миграций (Alembic)
- Настроить CI (тесты, линтер)
- Конфигурацию для production (gunicorn/uvicorn workers, настройки Nginx)

Если нужно, могу подготовить:
- пример `.env.example` с рекомендуемыми переменными
- инструкции по деплою (Docker + systemd / Kubernetes)

---
Автор: команда проекта
