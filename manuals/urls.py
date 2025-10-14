from django.contrib import admin
from django.urls import path
from django.views.decorators.csrf import csrf_exempt
from manuals import views

manuals_patterns = [
    path('manual_upload', views.manual_upload,name="manual_upload"),
    path('manual_upload_list', views.manual_upload_list,name="manual_upload_list"),
    ]