from flask import Flask
import psycopg2
import os
import random
app = Flask(__name__)
def get_db():
    conn = psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )
    return conn

def seed_words():
    words = ['devops', 'docker', 'container', 'volume', 'network',
             'nginx', 'proxy', 'pipeline', 'deploy', 'kubernetes']
    conn = get_db()
    cur = conn.cursor()
    cur.execute('CREATE TABLE IF NOT EXISTS words (id SERIAL, word TEXT)')
    cur.execute('SELECT count(*) FROM words')
    count = cur.fetchone()[0]
    if count == 0:
        for w in words:
            cur.execute('INSERT INTO words (word) VALUES (%s)', (w,))
    conn.commit()
    cur.close()
    conn.close()

@app.route('/')
def index():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('SELECT word FROM words')
    rows = cur.fetchall()
    cur.close()
    conn.close()
    word = random.choice(rows)[0]
    return 'Rastgele kelime: {}'.format(word)

if __name__ == '__main__':
    seed_words()
    app.run(host='0.0.0.0', port=5000)

