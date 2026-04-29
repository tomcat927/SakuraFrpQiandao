import logging
import os
from typing import Optional
from dataclasses import dataclass

# 尝试加载 .env 文件
try:
    from dotenv import load_dotenv
    load_dotenv(override=True)
except ImportError:
    pass

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('checkin.log', encoding='utf-8')
    ]
)
logger = logging.getLogger(__name__)


@dataclass
class Config:
    """配置数据类"""
    sakurafrp_user: str
    sakurafrp_pass: str
    base_url: str
    api_key: str
    model: str
    chrome_binary_path: Optional[str] = None
    max_retries: int = 10
    
    @classmethod
    def from_env(cls) -> 'Config':
        """从环境变量加载配置"""
        def get_env(key: str, required: bool = True) -> str:
            value = os.environ.get(key, "").split('\n')[0].strip()
            if required and not value:
                raise ValueError(f"环境变量 {key} 未设置或为空")
            return value
        
        return cls(
            sakurafrp_user=get_env("SAKURAFRP_USER"),
            sakurafrp_pass=get_env("SAKURAFRP_PASS"),
            base_url=get_env("BASE_URL"),
            api_key=get_env("API_KEY"),
            model=get_env("MODEL"),
            chrome_binary_path=get_env("CHROME_BINARY_PATH", required=False),
            max_retries=int(get_env("MAX_RETRIES", required=False) or 10)
        )
