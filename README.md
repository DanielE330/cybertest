# 🧪 CyberTest

> Приложение для тестирования студентов — монорепозиторий с бэкендом на FastAPI и фронтендом на Flutter.

---

## 📂 Структура

| Папка | Что внутри |
|---|---|
| [`backend/`](https://github.com/DanielE330/test-online/tree/main/backend) | API на FastAPI, Docker Compose, эндпоинты (`ENDPOINTS.md`) |
| [`cybertest/`](https://github.com/DanielE330/test-online/tree/main/cybertest) | Flutter-приложение (мобильные/веб сборки) |

## 🏃 Быстрый старт

### Бэкенд (с Docker)
```bash
cd backend
docker-compose up --build
```

### Бэкенд (локально)
```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Фронтенд
```bash
cd cybertest
flutter pub get
flutter run          # или flutter build для релиза
```

## 📖 Документация

- [`backend/ENDPOINTS.md`](https://github.com/DanielE330/test-online/blob/main/backend/ENDPOINTS.md) — список API-эндпоинтов
- [`backend/QUICK_REFERENCE.md`](https://github.com/DanielE330/test-online/blob/main/backend/QUICK_REFERENCE.md) — быстрая справка
- [`cybertest/SETUP_AUTH.md`](https://github.com/DanielE330/test-online/blob/main/cybertest/SETUP_AUTH.md) — настройка авторизации

## 🔑 Как контрибьютить

Форк → ветка `feat/описание` → PR с описанием изменений, следуя существующему код-стайлу.
