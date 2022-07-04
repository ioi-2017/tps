import sys
from color_util import cwrite, colors


class VerbosePrinter:

    default_color = colors.CYAN

    def __init__(self, enabled=False, color=default_color, stream=None):
        self._enabled = enabled
        self._color = color
        self._stream = sys.stderr if stream is None else stream

    @property
    def enabled(self):
        return self._enabled

    @enabled.setter
    def enabled(self, enabled):
        self._enabled = enabled

    @property
    def color(self):
        return self._color

    @color.setter
    def color(self, color):
        self._color = color

    @property
    def stream(self):
        return self._stream

    @stream.setter
    def stream(self, stream):
        self._stream = stream

    def enable(self):
        self.enabled = True

    def disable(self):
        self.enabled = False

    def _write(self, text):
        self.stream.write(text)

    def _cwrite(self, text):
        if self.color is None:
            self._write(text)
        else:
            cwrite(self.stream, self.color, text)

    def write(self, text):
        if self.enabled:
            self._cwrite(text)

    def print(self, text):
        if self.enabled:
            self._cwrite(text)
            self._write("\n")

    def value_repr(self, value):
        #pylint: disable=no-self-use
        return '%r' % value

    def print_var(self, var_name, var_value):
        if self.enabled:
            self._cwrite("{}=".format(var_name))
            self._write(" {}\n".format(self.value_repr(var_value)))

    def func_repr(self, func_name, *args, **kwargs):
        #pylint: disable=no-self-use
        args_str = ', '.join(
            [self.value_repr(value) for value in args] +
            ["{}={}".format(name, self.value_repr(value)) for name, value in kwargs.items()]
        )
        return "{}({})\n".format(func_name, args_str)

    def print_run(self, func_name, *args, **kwargs):
        if self.enabled:
            self._cwrite("RUN: ")
            self._write(self.func_repr(func_name, *args, **kwargs))

    def run(self, func_name, func, *args, **kwargs):
        self.print_run(func_name, *args, **kwargs)
        return func(*args, **kwargs)
