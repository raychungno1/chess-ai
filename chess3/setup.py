from distutils.core import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize([
        "src/board.pyx",
        "src/helper.pyx",
        "src/attack.pyx",
        "src/const.pyx",
        "src/move.pyx"
    ]),
    extra_compile_args=["-Ofast"]
)
