import os
import sys
import time
import threading
import webbrowser
from http.server import HTTPServer, SimpleHTTPRequestHandler
import webview

# 配置
PORT = 8000
SERVER_ADDRESS = ('', PORT)
GAME_HTML = 'index.html'

class CustomHandler(SimpleHTTPRequestHandler):
    """自定义请求处理器，用于处理游戏文件请求"""
    def end_headers(self):
        # 添加CORS头，允许本地文件访问
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        # 抑制日志输出
        return

def run_server():
    """启动本地HTTP服务器"""
    server = HTTPServer(SERVER_ADDRESS, CustomHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()
    print(f"Server running on http://localhost:{PORT}")
    return server

def launch_game():
    """启动游戏窗口"""
    # 等待服务器启动
    time.sleep(1)
    
    # 创建webview窗口
    window = webview.create_window(
        '4Ascend Game',
        url=f'http://localhost:{PORT}/{GAME_HTML}',
        width=1024,
        height=768,
        resizable=True,
        fullscreen=False
    )
    
    # 启动webview事件循环
    webview.start()

def main():
    try:
        # 检查是否已安装webview依赖
        import webview
    except ImportError:
        print("Error: PyWebView library not found.")
        print("Please install it using: pip install pywebview")
        sys.exit(1)

    # 切换到项目根目录
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # 启动服务器
    server = run_server()
    
    try:
        # 启动游戏
        launch_game()
    finally:
        # 关闭服务器
        print("Shutting down server...")
        server.shutdown()
        print("Server shutdown complete.")

if __name__ == '__main__':
    main()

# Note: This script requires the PyWebView library
# Install with: pip install pywebview
# For Windows, you may also need to install Visual C++ Redistributable
# More info: https://pywebview.flowrl.com/installation.html