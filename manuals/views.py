from django.shortcuts import render
from django.core.files.storage import FileSystemStorage
from django.contrib import messages
from django.shortcuts import render,redirect,get_object_or_404
from manuals.models import Manuals
from pathlib import Path
from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
from core.utils import *

def manual_upload(request):
    if request.method=='POST' and request.FILES['myfile']:
        myfile= request.FILES['myfile']
        extension=Path(myfile.name).suffix
        if extension=='.pdf':
            fs= FileSystemStorage()
            filename = fs.save(myfile.name, myfile)
            uploaded_file_url=fs.url(filename)
            manual_name = request.POST.get('manual_name')
            manual_description= request.POST.get('manual_description')
            manuals_save = Manuals(
                manual_name = manual_name.title(),
                manual_path = uploaded_file_url,
                manual_description=manual_description.title(),
                )
            manuals_save.save()
            messages.add_message(request, messages.INFO, 'Manual ingresado')
            return render(request,'manuals/subida.html',{
                'uploaded_file_url': uploaded_file_url
            })
        else:
            messages.add_message(request, messages.INFO, 'Solo se permiten arhivos PDF')
    return render(request, 'manuals/subida.html')

def manual_upload_list(request,page=None):
    manuals_list = Manuals.objects.all()
    page = request.GET.get('page')
    paginator = Paginator(manuals_list , QUANTITY_LIST)
    manuals_list_pag = paginator.get_page(page)
    template_name = 'manuals/subida.html'    
    return render(request, template_name, {'manuals_list_pag':manuals_list_pag,'paginator':paginator})
    
