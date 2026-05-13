from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json()
    print("Received:", data)

    return jsonify({
        "message": f"Received {data['name']} with email {data['email']}"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)