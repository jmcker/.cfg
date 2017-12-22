python
import sys
sys.path.insert(0, '/homes/jmckern/bin/gdb_printers')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end
