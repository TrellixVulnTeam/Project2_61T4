#!f:\python-django-project\project2\virdir\scripts\python.exe
# EASY-INSTALL-ENTRY-SCRIPT: 'pip==10.0.0b1','console_scripts','pip'
__requires__ = 'pip==10.0.0b1'
import re
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw?|\.exe)?$', '', sys.argv[0])
    sys.exit(
        load_entry_point('pip==10.0.0b1', 'console_scripts', 'pip')()
    )
