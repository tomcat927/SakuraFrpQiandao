# SakuraFrp 自动签到脚本

使用 Playwright 驱动浏览器，并通过 AI 视觉识别完成 SakuraFrp 九宫格验证码签到。

## 功能特性

- 自动登录 SakuraFrp 账户
- AI 视觉识别九宫格验证码
- 自动点击匹配的验证码格子
- 失败自动重试，默认最多 10 次
- 支持 GitHub Actions 定时执行
- 支持邮件通知和日志归档

## 本地运行

### 1. 环境准备

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

本项目默认优先使用本机已安装的 Chrome，不需要下载 ChromeDriver，也不强制执行 `playwright install chromium`。

如果本机没有 Chrome，或希望使用 Playwright 托管浏览器，可以执行：

```bash
python -m playwright install chromium
```

### 2. 配置环境变量

创建 `.env` 文件：

```env
SAKURAFRP_USER=your_username
SAKURAFRP_PASS=your_password

BASE_URL=https://api.example.com/v1
API_KEY=your_api_key
MODEL=your_model_name

MAX_RETRIES=10
HEADLESS=false
CHROME_BINARY_PATH=
```

`CHROME_BINARY_PATH` 可选。留空时会自动查找系统 Chrome；如果你的 Chrome 不在默认位置，可以显式指定：

```env
CHROME_BINARY_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe
```

Playwright 只复用 Chrome 可执行文件，不会读取你日常 Chrome 的用户目录、Cookie、历史记录或扩展。

### 3. 运行脚本

```bash
python main.py
```

## GitHub Actions 部署

工作流文件位于 `.github/workflows/sakurafrp_sign.yml`，默认每天北京时间 9:00 执行，也支持手动触发。

需要配置以下 Secrets：

| 名称 | 说明 |
| --- | --- |
| `SAKURAFRP_USER` | SakuraFrp 用户名 |
| `SAKURAFRP_PASS` | SakuraFrp 密码 |
| `BASE_URL` | OpenAI 兼容 API 地址 |
| `API_KEY` | API 密钥 |
| `MODEL` | 多模态模型名称 |

邮件通知为可选配置：

| 名称 | 说明 |
| --- | --- |
| `EMAIL_USERNAME` | 发件邮箱 |
| `EMAIL_PASSWORD` | 邮箱授权码或应用密码 |
| `RECEIVER_EMAIL` | 收件邮箱，默认发给自己 |
| `SMTP_SERVER` | SMTP 服务器，默认 `smtp.gmail.com` |
| `SMTP_PORT` | SMTP 端口，默认 `587` |

Actions 使用 GitHub runner 自带 Chrome，并执行 `python -m playwright install-deps chromium` 安装 Linux 运行依赖，避免每次下载 Playwright Chromium 大包。

## 项目结构

```text
SakuraFrp-Qiandao/
├── .github/workflows/sakurafrp_sign.yml
├── automation.py          # Playwright 签到主流程
├── captcha_handler.py     # GeeTest 验证码识别和点击
├── config.py              # 环境变量和日志配置
├── human_simulator.py     # 简单人类操作模拟
├── main.py                # 程序入口
├── send_email.py          # 邮件通知
├── requirements.txt       # Python 依赖
└── README.md
```

## 配置说明

### 定时任务时间

修改 `.github/workflows/checkin.yml` 中的 cron 表达式：

```yaml
schedule:
  - cron: '0 1 * * *'  # UTC 1:00 = 北京时间 9:00
```

常用时间对照：
- `0 1 * * *` - 每天 9:00（北京时间）
- `0 13 * * *` - 每天 21:00（北京时间）
- `0 1,13 * * *` - 每天 9:00 和 21:00

### AI 模型推荐

支持任何兼容 OpenAI API 的多模态模型：

- **OpenAI**: `gpt-4o`, `gpt-4-vision-preview`
- **阿里通义**: `qwen-vl-plus`, `qwen-vl-max`
- **智谱 AI**: `glm-4v`
- **ModelScope**: 各种开源视觉模型

## 故障排查

### 问题：验证码识别失败

**原因**：AI 模型识别不准确

**解决方案**：
1. 尝试更换更强大的视觉模型
2. 优化 Prompt 提示词
3. 增加重试次数

### 问题：GitHub Actions 运行失败

**原因**：环境问题或依赖安装失败

**解决方案**：
1. 检查 Secrets 是否正确配置
2. 查看 Actions 日志中的具体错误
3. 确保 requirements.txt 中的依赖版本正确

### 问题：登录失败

**原因**：账号密码错误或网络问题

**解决方案**：
1. 验证 Secrets 中的用户名密码
2. 检查账号是否正常
3. 查看日志中的详细错误信息

### 问题：未收到邮件通知

**原因**：邮箱配置错误或 SMTP 服务未开启

**解决方案**：
1. 检查 `EMAIL_USERNAME` 和 `EMAIL_PASSWORD` 是否正确配置
2. 确认使用的是**应用专用密码**，不是登录密码
3. 检查邮箱是否开启了 SMTP 服务
4. 查看 Actions 日志中的邮件发送错误信息
5. 检查垃圾邮件文件夹

## 注意事项

⚠️ **重要提示**：

1. 请勿频繁触发 Actions，避免被限流
2. 妥善保管 API 密钥和邮箱密码，不要泄露
3. 定期检查签到日志或邮件，确保正常运行
4. 遵守 SakuraFrp 的服务条款
5. **邮箱应用密码不是登录密码**，Gmail 需要开启两步验证后生成应用专用密码
6. 邮件通知是可选的，不配置也不影响签到功能

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [SakuraFrp 官网](https://www.natfrp.com/)
- [Selenium 文档](https://www.selenium.dev/documentation/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)