from pathlib import Path
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

# ── SEGURANSA ─────────────────────────────────────────────────────────
SECRET_KEY = 'django-insecure-absensi-instansi-pemerintah-change-this-in-production'
DEBUG = True  # Troka ba False wanhira produsaun

# Fó lisensa asesu husi HP fíziku & emuladór iha rede lokál
ALLOWED_HOSTS = ['*']

# ── APLIKASAUN ──────────────────────────────────────────────────────────
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'api',
    'drf_spectacular',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Tenke tau iha pozisaun leten liu
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'absensi_admin.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'absensi_admin.wsgi.application'

# ── DATABASE MySQL (XAMPP) ────────────────────────────────────────────
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'db_absensi',          # Naran baze de dadus iha XAMPP
        'USER': 'root',                # Uza-na'in padraun XAMPP
        'PASSWORD': '',                # Password XAMPP (mamuk padraun)
        'HOST': '127.0.0.1',
        'PORT': '3306',
        'OPTIONS': {
            'charset': 'utf8mb4',
        },
    }
}

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=8),    # Token vale ba oras 8 (shift servisu 1)
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# ── CORS (Fó lisensa asesu husi Flutter App) ─────────────────────────────
CORS_ALLOW_ALL_ORIGINS = True  # Troka ba CORS_ALLOWED_ORIGINS espesífiku iha produsaun

# ── KONFIGURASAUN SELUK ────────────────────────────────────────────────
LANGUAGE_CODE = 'id-id'
TIME_ZONE = 'Asia/Makassar'   # Ajusta tuir zona horária instánsia
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ── Modelu Uza-na'in Kustom ─────────────────────────────────────────────
AUTH_USER_MODEL = 'api.Funsonariu'

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ── Spectacular Settings ─────────────────────────────────────────────
SPECTACULAR_SETTINGS = {
    'TITLE': 'API Sistema Presensa Biometria',
    'DESCRIPTION': 'Dokumentasaun API ba sistema presensa instánsia governu nian.',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}
