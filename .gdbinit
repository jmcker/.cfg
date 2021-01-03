# https://stackoverflow.com/a/5713387/6798110
python

import sys
import os

sys.path.insert(0, os.path.expandvars('${HOME}/.gdb'))
sys.path.insert(0, os.path.expandvars('${HOME}/.gdb/stdcxx'))

from libstdcxx.v6.printers import register_libstdcxx_printers
from qt import register_qt_printers

register_libstdcxx_printers (None)
register_qt_printers (None)

print('')
print('Loaded STL pretty-printer')
print('Loaded Qt pretty-printer')
print('''Type: 'loadgef' to start gef''')
print('')

end

define loadgef
    source ~/.gdb/gef.py
end
