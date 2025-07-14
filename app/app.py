from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Flask on EC2 via GitHub Actions! (v1.0)"

if __name__ == '__main__':
    # Use 0.0.0.0 to make it accessible from outside the container
    app.run(host='0.0.0.0', port=os.environ.get('PORT', 5000))
