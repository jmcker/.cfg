python
import sys
import os
sys.path.insert(0, os.path.expandvars('$HOME/bin/gdb_printers'))
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end

define loadgef
    source /mnt/d/jmcker/.gdbinit-gef.py
end
