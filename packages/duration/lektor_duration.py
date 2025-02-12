from lektor.pluginsystem import Plugin
from datetime import datetime


def duration(start, end):
    if not isinstance(start, datetime) or not isinstance(end, datetime):
        return "Invalid datetime values"

    duration = end - start
    return duration

class DurationPlugin(Plugin):
    name = 'duration'
    description = u'Calculate duration from two datetimes'

    def on_setup_env(self, **extra):
        self.env.jinja_env.filters["duration"] = duration

