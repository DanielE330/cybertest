from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import crud, models, schemas, auth
from ..database import get_db
from datetime import timedelta

router = APIRouter()

@router.post("/register", response_model=schemas.Token)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    import logging
    logger = logging.getLogger(__name__)
    
    logger.info(f"[REGISTER] User registration: name={user.name}, status={user.status}")
    
    db_user = crud.get_user_by_name(db, name=user.name)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    db_user = crud.create_user(db=db, user=user)
    
    logger.info(f"[REGISTER] User registered: id={db_user.id}, status={db_user.status}")
    
    # Auto-login after registration
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": db_user.name}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=schemas.Token)
def login(user: schemas.UserCreate, db: Session = Depends(get_db)):
    import logging
    logger = logging.getLogger(__name__)
    
    logger.info(f"[LOGIN] Attempt: name={user.name}, status={user.status}")
    
    db_user = auth.authenticate_user(db, user.name, user.password)
    if not db_user:
        logger.warning(f"[LOGIN] Failed: name={user.name}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    logger.info(f"[LOGIN] Success: id={db_user.id}, name={db_user.name}, status={db_user.status}")
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": db_user.name}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
@router.get("/me", response_model=schemas.User)
def get_current_user_info(current_user: models.User = Depends(auth.get_current_user)):
    """Get current authenticated user info. Use this to verify token is valid."""
    return current_user
