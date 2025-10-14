from django.contrib.auth.decorators import login_required
from administrator.models import Config
from registration.models import Profile

#Constantes
QUANTITY_LIST = 100

#Metodos estandar
@login_required
def retrun_url_base(request):
    config_data = Config.objects.get(pk=1)
    return config_data.base_url
@login_required
def type_flow(request):
    config_data = Config.objects.get(pk=1)
    return config_data.app_type
@login_required
def check_profile_admin(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return 0
    if profiles.group_id != 1:
        return 0
    return 1
@login_required
def check_profile_territorial(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return 0
    if profiles.group_id != 2:
        return 0
    return 1
@login_required
def check_profile_department(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return 0
    if profiles.group_id != 3:
        return 0
    return 1
@login_required
def check_profile_management(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return 0
    if profiles.group_id != 4:
        return 0
    return 1
@login_required
def check_profile_brigade(request):
    try:
        profiles = Profile.objects.get(user_id = request.user.id)
    except Profile.DoesNotExist:
        return 0
    if profiles.group_id != 5:
        return 0
    return 1