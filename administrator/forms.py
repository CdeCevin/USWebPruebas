from django import forms
from django.contrib.auth.models import User, Group
from administrator.models import Config,Logo

def upload_logo_form(config_id):
    class UploadLogoForm(forms.ModelForm):
        home = forms.ModelChoiceField(label=False,initial=config_id,required=False,queryset=Config.objects.filter(pk=config_id),widget=forms.Select(attrs={'class':'d-none'}))
        path = forms.FileField(label=False)
        class Meta:
            model = Logo
            fields = ['path']
            widgets = {
                'path' : forms.ClearableFileInput(attrs={'class':'form-control-file mt-3'}),
                }
    return UploadLogoForm

class UploadLogoForm(forms.ModelForm):
    class Meta:
        model = Logo
        fields = ['path']