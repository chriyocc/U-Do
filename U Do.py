#!/usr/bin/env python3

import os
import subprocess
from Cocoa import NSApplication, NSStatusBar, NSVariableStatusItemLength, NSMenu, NSMenuItem, NSObject, NSTimer, NSColor, NSAttributedString, NSForegroundColorAttributeName
from PyObjCTools import AppHelper

# File paths for storing tasks and current index
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TODO_FILE = os.path.join(BASE_DIR, ".todo_list")
INDEX_FILE = os.path.join(BASE_DIR, ".todo_index")
INTERVAL_FILE = os.path.join(BASE_DIR, ".todo_interval")

# Default time interval in seconds
DEFAULT_INTERVAL = 5.0

def load_tasks():
    """Load tasks from the to-do file."""
    if not os.path.exists(TODO_FILE):
        with open(TODO_FILE, "w") as f:
            f.write("Task 1\nTask 2\nTask 3")
    with open(TODO_FILE, "r") as f:
        tasks = [line.strip() for line in f if line.strip()]
    return tasks

def load_completed_tasks():
    """Load completed tasks from the completed tasks file."""
    return []

def load_index():
    """Load the current task index."""
    if not os.path.exists(INDEX_FILE):
        return 0
    with open(INDEX_FILE, "r") as f:
        try:
            return int(f.read().strip())
        except ValueError:
            return 0

def save_index(index):
    """Save the current task index."""
    with open(INDEX_FILE, "w") as f:
        f.write(str(index))

def save_tasks(tasks):
    """Save tasks back to the to-do file."""
    with open(TODO_FILE, "w") as f:
        f.write("\n".join(tasks))

def save_completed_tasks(tasks):
    """Save completed tasks back to the completed tasks file."""
    pass

def load_interval():
    """Load the time interval from the interval file."""
    if not os.path.exists(INTERVAL_FILE):
        return DEFAULT_INTERVAL
    with open(INTERVAL_FILE, "r") as f:
        try:
            return float(f.read().strip())
        except ValueError:
            return DEFAULT_INTERVAL

def save_interval(interval):
    """Save the time interval to the interval file."""
    with open(INTERVAL_FILE, "w") as f:
        f.write(str(interval))

def set_interval_with_ui():
    """Launch AppleScript UI to set the time interval."""
    script = '''
    set newInterval to text returned of (display dialog "Enter time interval in seconds:" default answer "")
    return newInterval
    '''
    try:
        result = subprocess.check_output(["osascript", "-e", script]).decode("utf-8").strip()
        if result:
            interval = float(result)
            save_interval(interval)
            return interval
    except (subprocess.CalledProcessError, ValueError):
        pass  # User canceled the dialog or entered an invalid value
    return load_interval()

def get_next_task(tasks):
    """Get the next task in the list."""
    index = load_index()
    if not tasks:
        return "No tasks available"  # Return the default message if no tasks exist
    next_task = tasks[index % len(tasks)]
    save_index((index + 1) % len(tasks))  # Update the index for the next task
    return next_task.strip()  # Ensure no trailing characters are added

def mark_task_completed(task):
    """Mark a task as completed."""
    tasks = load_tasks()
    if task in tasks:
        tasks.remove(task)
        save_tasks(tasks)

def edit_tasks_with_ui():
    """Launch AppleScript UI to edit tasks."""
    tasks = load_tasks()
    task_list = "\n".join(f"{i+1}. {task}" for i, task in enumerate(tasks))

    script = f'''
    set taskList to "{task_list}"
    set action to button returned of (display dialog "To-Do List:\\n" & taskList buttons {{"Add Task", "Cancel"}} default button "Cancel")
    
    if action is "Add Task" then
        set newTask to text returned of (display dialog "Enter new task:" default answer "")
        set priority to button returned of (display dialog "Set priority:" buttons {{"High", "Normal"}} default button "Normal")
        if priority is "High" then
            set newTask to "🔴 " & newTask 
        end if
        return "add:" & newTask
    end if
    '''
    try:
        result = subprocess.check_output(["osascript", "-e", script]).decode("utf-8").strip()
        if result.startswith("add:"):
            new_task = result.replace("add:", "").strip()
            if new_task:
                tasks.append(new_task)
        save_tasks(tasks)
    except subprocess.CalledProcessError:
        pass  # User canceled the dialog

# Main Menu Bar App Class
class ToDoMenuApp(NSObject):
    def applicationDidFinishLaunching_(self, notification):
        self.tasks = load_tasks()
        self.interval = load_interval()
        self.status_bar = NSStatusBar.systemStatusBar()
        self.status_item = self.status_bar.statusItemWithLength_(NSVariableStatusItemLength)
        self.status_item.setTitle_("Loading...")
        self.menu = NSMenu.alloc().init()

        # Add menu items
        self.update_task_menu()

        self.status_item.setMenu_(self.menu)

        # Timer to rotate tasks
        self.timer = NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            self.interval, self, "updateTask:", None, True
        )

    def update_task_menu(self):
        """Update the task displayed in the menu."""
        current_task = get_next_task(self.tasks)
        self.status_item.setTitle_(current_task)  # Set only the task text
        self.menu.removeAllItems()
        for task in self.tasks:
            task_item = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_(task, "removeTask:", "")
            task_item.setRepresentedObject_(task)
            self.menu.addItem_(task_item)
        self.menu.addItem_(NSMenuItem.separatorItem())
        self.menu.addItemWithTitle_action_keyEquivalent_("Edit To-Do List", "editTasks:", "")
        self.menu.addItemWithTitle_action_keyEquivalent_("Set Time Interval", "setInterval:", "")
        self.menu.addItemWithTitle_action_keyEquivalent_("Quit", "terminate:", "")

    def create_white_text(self, text):
        """Create an attributed string with white text."""
        attributes = {NSForegroundColorAttributeName: NSColor.whiteColor()}
        return NSAttributedString.alloc().initWithString_attributes_(text, attributes)

    def removeTask_(self, sender):
        """Remove the selected task."""
        task = sender.representedObject()
        tasks = load_tasks()
        if task in tasks:
            tasks.remove(task)
            save_tasks(tasks)
            self.tasks = tasks
            self.update_task_menu()

    def updateTask_(self, timer):
        """Called by timer to update the task."""
        self.tasks = load_tasks()
        self.update_task_menu()

    def editTasks_(self, sender):
        """Edit tasks using AppleScript UI."""
        edit_tasks_with_ui()
        self.tasks = load_tasks()
        self.update_task_menu()

    def setInterval_(self, sender):
        """Set the time interval using AppleScript UI."""
        self.interval = set_interval_with_ui()
        self.timer.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            self.interval, self, "updateTask:", None, True
        )

def main():
    app = NSApplication.sharedApplication()
    delegate = ToDoMenuApp.alloc().init()
    app.setDelegate_(delegate)
    AppHelper.runEventLoop()

if __name__ == "__main__":
    main()
