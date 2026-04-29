import time
import random


class HumanSimulator:
    """模拟人类行为"""
    
    @staticmethod
    def type_text(element, text: str, min_delay: float = 0.05, max_delay: float = 0.2):
        """模拟人类打字"""
        for char in text:
            element.type(char, delay=0)
            time.sleep(random.uniform(min_delay, max_delay))
    
    @staticmethod
    def random_sleep(min_sec: float = 1.0, max_sec: float = 3.0):
        """随机等待"""
        time.sleep(random.uniform(min_sec, max_sec))
