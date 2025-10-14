from django.urls import path
from management import views

management_patterns = [
    path('management_list_active', views.management_list_active,name="management_list_active"),
    path('management_list_active/<page>/', views.management_list_active,name="management_list_active"),
    path('management_list_block', views.management_list_block,name="management_list_block"),
    path('management_list_block/<page>/', views.management_list_block,name="management_list_block"),
    path('management_add', views.management_add,name="management_add"),
    path('management_block/<management_id>/', views.management_block,name="management_block"),
    path('management_activate/<management_id>/', views.management_activate,name="management_activate"),
    path('management_edit/<management_id>/', views.management_edit,name="management_edit"),
    path('management_edit_save/', views.management_edit_save,name="management_edit_save"),

    path('report_list_actives/', views.report_list_actives, name='report_list_actives'),
    path('report_list_block/', views.report_list_block, name='report_list_block'),
]   