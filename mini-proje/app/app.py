from flask import Flask
import psycopg2
import os

app = Flask(__name__)

def get_db():
    conn = psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )
    return conn

@app.route('/')
def index():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('CREATE TABLE IF NOT EXISTS visits (count INT)')
    cur.execute('SELECT count FROM visits')
    row = cur.fetchone()
    if row is None:
        cur.execute('INSERT INTO visits VALUES (1)')
        count = 1
    else:
        count = row[0] + 1
        cur.execute('UPDATE visits SET count = %s', (count,))
    conn.commit()
    cur.close()
    conn.close()
    return 'Ziyaret sayisi: {}'.format(count)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
