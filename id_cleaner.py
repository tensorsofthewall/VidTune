import os
import time
import shutil
import logging
from datetime import datetime, timedelta
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Configure logging
FORMAT = "%(asctime)s: %(levelname)s: %(message)s"
logging.basicConfig(filename="logs.log", level=logging.INFO, format=FORMAT)
STDERRLOGGER = logging.StreamHandler()
STDERRLOGGER.setFormatter(logging.Formatter(FORMAT))
logging.getLogger().addHandler(STDERRLOGGER)

class DirectoryCleanupHandler(FileSystemEventHandler):
    def __init__(self, threshold_minutes=60, check_interval_minutes=5):
        self.threshold = timedelta(minutes=threshold_minutes)
        self.check_interval = check_interval_minutes * 60
        self.last_check_time = datetime.now()

    def on_modified(self, event):
        if event.is_directory and event.src_path.startswith("_id_"):
            logging.info(f"Detected modification in directory: {event.src_path}")
            self.cleanup_directories()

    def cleanup_directories(self):
        now = datetime.now()
        for dirpath, _, _ in os.walk("."):
            if os.path.basename(dirpath).startswith("_id_"):
                try:
                    mtime = os.path.getmtime(dirpath)
                    mtime_dt = datetime.fromtimestamp(mtime)
                    if now - mtime_dt > self.threshold:
                        logging.info(f"Deleting directory: {dirpath}")
                        shutil.rmtree(dirpath)
                except Exception as e:
                    logging.error(f"Error deleting {dirpath}: {e}")

    def start_cleanup_loop(self):
        while True:
            current_time = datetime.now()
            if (
                current_time - self.last_check_time
            ).total_seconds() >= self.check_interval:
                logging.info("Woke up to check directories")
                self.cleanup_directories()
                self.last_check_time = current_time
            time.sleep(self.check_interval)


if __name__ == "__main__":
    logging.info("Starting directory cleanup script")
    event_handler = DirectoryCleanupHandler(
        threshold_minutes=60, check_interval_minutes=30
    )
    observer = Observer()
    observer.schedule(event_handler, path=".", recursive=True)
    observer.start()

    try:
        event_handler.start_cleanup_loop()
    except KeyboardInterrupt:
        logging.info("Stopping directory cleanup script due to keyboard interrupt")
        observer.stop()
    observer.join()
