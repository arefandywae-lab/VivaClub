from django.shortcuts import render
from django.views import View

class MobileTestView(View):
    def get(self, request):
        return render(request, 'mobile_test.html')

class MobileTestV2View(View):
    def get(self, request):
        return render(request, 'mobile_v2.html')
