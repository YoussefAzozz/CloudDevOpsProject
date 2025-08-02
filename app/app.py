from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
from mysql.connector import Error
import os

app = Flask(__name__)

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DATABASE_NAME")
        )
        return connection
    except Error as e:
        print("Error connecting to MySQL:", e)
        return None

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        username = request.form.get("username")
        email = request.form.get("email")
        connection = get_db_connection()
        if connection:
            try:
                cursor = connection.cursor()
                cursor.execute("INSERT INTO users (username, email) VALUES (%s, %s)", (username, email))
                connection.commit()
                cursor.close()
                connection.close()
                return redirect(url_for("index"))
            except Error as e:
                return f"Error inserting data: {e}"
        else:
            return "Database connection failed"
    return render_template("index.html")

@app.route("/users")
def list_users():
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor()
        cursor.execute("SELECT username, email FROM users")
        rows = cursor.fetchall()
        cursor.close()
        connection.close()
        return render_template("index.html", data=rows)
    else:
        return "Database connection failed"

@app.route("/healthz")
def liveness():
    return "OK", 200

@app.route("/readyz")
def readiness():
    try:
        connection = get_db_connection()
        if connection and connection.is_connected():
            connection.close()
            return "READY", 200
        else:
            return "DB not connected", 500
    except:
        return "DB connection failed", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


