import http.server
import socketserver

class GodotHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Эти два заголовка критически важны для работы потоков в Godot 4
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

PORT = 8000
with socketserver.TCPServer(("", PORT), GodotHandler) as httpd:
    httpd.allow_reuse_address = True
    print(f"Сервер запущен на http://localhost:{PORT}")
    httpd.serve_forever()

