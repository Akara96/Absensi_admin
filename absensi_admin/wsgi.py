"""
Konfigurasaun WSGI ba projetu absensi_admin.

Nia esplora kualidade WSGI hanesan de'it ho variável nivel-mudu `application`.

Informasaun liután, favor haree:
https://docs.djangoproject.com/en/4.2/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'absensi_admin.settings')

application = get_wsgi_application()
