import time
import watchdog.events
import watchdog.observers
import subprocess

class FileChangeHandler(watchdog.events.FileSystemEventHandler):
    def __init__(self):
        super().__init__()
        self.last_modified = time.time()

    def on_modified(self, event):
        if event.src_path.endswith("input.txt"):
            current_time = time.time()
            if current_time - self.last_modified > 0.5:
                self.last_modified = current_time
                time.sleep(0.1)
                try:
                    subprocess.run(["iverilog", "-o", "tb.vvp", "tb.v"], check = True)
                    subprocess.run(["vvp", "tb.vvp"], check=True)
                except subprocess.CalledProcessError as e:
                    print(f"An error occured: {e}")

if __name__ == "__main__":
    event_handler = FileChangeHandler()
    observer = watchdog.observers.Observer()
    observer.schedule(event_handler, path='.', recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
