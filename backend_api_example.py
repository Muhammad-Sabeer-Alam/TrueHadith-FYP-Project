"""

I didn't find anything related to check the user input either it is Urdu, Roman urdu, English or Arabic.
I didn't find anything related for audio transcription.


This file is the backend API for the Flutter app.
It is used to authenticate users, search hadiths, and save search history.
It is written in Python using Flask and PostgreSQL.
It uses FAISS for semantic similarity search and OpenAI for embedding.
It uses CORS to allow the Flutter app to access the API.
It uses the dotenv package to load the environment variables from the .env file.
It uses the faiss package for FAISS.
It uses the pandas package for data manipulation.
It uses the numpy package for numerical operations.
It uses the openai package for OpenAI.
It uses the psycopg2 package for PostgreSQL.
It uses the flask_cors package for CORS.
It uses the flask package for the Flask application.
It uses the request package for the request object.
It uses the jsonify package for the jsonify object.
It uses the datetime package for the datetime object.
It uses the os package for the os object.
It uses the dotenv package for the dotenv object.
It uses the faiss package for the faiss object.
It uses the pandas package for the pandas object.
It uses the numpy package for the numpy object.
It uses the openai package for the openai object.
It uses the psycopg2 package for the psycopg2 object.
It uses the flask_cors package for the flask_cors object.
It uses the flask package for the flask object.
It uses the request package for the request object.
It uses the jsonify package for the jsonify object.
It uses the datetime package for the datetime object.
It uses the os package for the os object.
It uses the dotenv package for the dotenv object.
It uses the faiss package for the faiss object.
It uses the pandas package for the pandas object.
It uses the numpy package for the numpy object.
It uses the openai package for the openai object.

Flask Backend API Example
This file shows the expected Flask endpoints that should be implemented
to work with the Flutter app's authentication flow.

Install required packages:
pip install flask flask-cors psycopg2-binary python-dotenv faiss-cpu openai pandas numpy

Database Setup:
Make sure PostgreSQL is running and create the database with the schema provided.

FAISS Setup:
Place FAISS index files in: data/faiss/
Place mapping CSV files in: data/mapping/
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import os
from dotenv import load_dotenv
import re

# Optional heavy dependencies for AI search
try:
    import faiss
    import pandas as pd
    import numpy as np
    import openai
    HAS_AI_DEPS = True
except ImportError:
    print("⚠ Warning: AI dependencies (faiss, pandas, numpy, openai) not found. AI Search will be disabled.")
    HAS_AI_DEPS = False

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'database': os.getenv('DB_NAME', 'fyp_true_hadith'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'mojo123'),
    'port': os.getenv('DB_PORT', '5432')
}

# FAISS and Mapping File Paths
BUKHARI_FAISS_PATH = os.path.join('data', 'faiss', 'bukhari_faiss.index')
TIRMIZI_FAISS_PATH = os.path.join('data', 'faiss', 'tirmizi_faiss.index')
BUKHARI_MAPPING_PATH = os.path.join('data', 'mapping', 'bukhari_mapping.csv')
TIRMIZI_MAPPING_PATH = os.path.join('data', 'mapping', 'tirmizi_mapping.csv')

# Global variables to store loaded FAISS indexes and mappings
bukhari_index = None
tirmizi_index = None
bukhari_mapping = None
tirmizi_mapping = None

# OpenAI API Key
if HAS_AI_DEPS:
    openai.api_key = os.getenv('OPENAI_API_KEY', '')


def load_faiss_indexes():
    """Load FAISS indexes at startup"""
    global bukhari_index, tirmizi_index
    
    try:
        if os.path.exists(BUKHARI_FAISS_PATH):
            bukhari_index = faiss.read_index(BUKHARI_FAISS_PATH)
            print(f"✓ Loaded Bukhari FAISS index: {BUKHARI_FAISS_PATH}")
        else:
            print(f"⚠ Warning: Bukhari FAISS index not found at {BUKHARI_FAISS_PATH}")
            
        if os.path.exists(TIRMIZI_FAISS_PATH):
            tirmizi_index = faiss.read_index(TIRMIZI_FAISS_PATH)
            print(f"✓ Loaded Tirmizi FAISS index: {TIRMIZI_FAISS_PATH}")
        else:
            print(f"⚠ Warning: Tirmizi FAISS index not found at {TIRMIZI_FAISS_PATH}")
    except Exception as e:
        print(f"✗ Error loading FAISS indexes: {e}")


def load_mapping_csvs():
    """Load mapping CSV files at startup"""
    global bukhari_mapping, tirmizi_mapping
    
    try:
        if os.path.exists(BUKHARI_MAPPING_PATH):
            bukhari_mapping = pd.read_csv(BUKHARI_MAPPING_PATH)
            print(f"✓ Loaded Bukhari mapping CSV: {BUKHARI_MAPPING_PATH}")
        else:
            print(f"⚠ Warning: Bukhari mapping CSV not found at {BUKHARI_MAPPING_PATH}")
            
        if os.path.exists(TIRMIZI_MAPPING_PATH):
            tirmizi_mapping = pd.read_csv(TIRMIZI_MAPPING_PATH)
            print(f"✓ Loaded Tirmizi mapping CSV: {TIRMIZI_MAPPING_PATH}")
        else:
            print(f"⚠ Warning: Tirmizi mapping CSV not found at {TIRMIZI_MAPPING_PATH}")
    except Exception as e:
        print(f"✗ Error loading mapping CSVs: {e}")


# Load FAISS and mappings when server starts
if HAS_AI_DEPS:
    print("\n" + "="*50)
    print("Loading FAISS indexes and mapping files...")
    print("="*50)
    load_faiss_indexes()
    load_mapping_csvs()
    print("="*50 + "\n")
else:
    print("\n" + "="*50)
    print("Skipping AI Search initialization (dependencies missing)")
    print("="*50 + "\n")


def get_db_connection():
    """Create and return a database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        raise


@app.route('/api/auth/register', methods=['POST'])
def register_user():
    """
    Register a new user after Firebase authentication
    
    Expected JSON body:
    {
        "firebase_uid": "string",
        "username": "string",
        "email": "string"
    }
    
    Returns:
    {
        "user_id": int,
        "username": "string",
        "created_at": "ISO datetime string"
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        firebase_uid = data.get('firebase_uid')
        username = data.get('username')
        email = data.get('email')
        
        if not all([firebase_uid, username, email]):
            return jsonify({'message': 'Missing required fields'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Check if user already exists
        cursor.execute(
            "SELECT user_id FROM users WHERE FK_firebase_uid = %s",
            (firebase_uid,)
        )
        existing_user = cursor.fetchone()
        
        if existing_user:
            cursor.close()
            conn.close()
            return jsonify({'message': 'User already exists'}), 409
        
        # Insert new user
        cursor.execute(
            """
            INSERT INTO users (FK_firebase_uid, user_name, name_email, created_at)
            VALUES (%s, %s, %s, %s)
            RETURNING user_id, user_name, created_at
            """,
            (firebase_uid, username, email, datetime.now())
        )
        
        user = cursor.fetchone()
        conn.commit()
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'user_id': user['user_id'],
            'username': user['user_name'],
            'created_at': user['created_at'].isoformat(),
        }), 201
        
    except Exception as e:
        print(f"Registration error: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
            cursor.close()
            conn.close()
        return jsonify({'message': f'Registration failed: {str(e)}'}), 500


@app.route('/api/auth/login', methods=['POST'])
def login_user():
    """
    Login user and return user data
    
    Expected JSON body:
    {
        "firebase_uid": "string"
    }
    
    Returns:
    {
        "user_id": int,
        "username": "string",
        "created_at": "ISO datetime string"
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        firebase_uid = data.get('firebase_uid')
        
        if not firebase_uid:
            return jsonify({'message': 'Missing firebase_uid'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Find user by firebase_uid
        cursor.execute(
            """
            SELECT user_id, user_name, created_at
            FROM users
            WHERE FK_firebase_uid = %s
            """,
            (firebase_uid,)
        )
        
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        return jsonify({
            'user_id': user['user_id'],
            'username': user['user_name'],
            'created_at': user['created_at'].isoformat(),
        }), 200
        
    except Exception as e:
        print(f"Login error: {e}")
        if 'conn' in locals() and conn:
            cursor.close()
            conn.close()
        return jsonify({'message': f'Login failed: {str(e)}'}), 500


def normalize_arabic_text(text):
    """Normalize Arabic text: remove tashkeel, normalize alif/ya"""
    # Remove Arabic diacritics (tashkeel)
    text = re.sub(r'[\u064B-\u065F\u0670]', '', text)
    
    # Normalize Alif variations
    text = re.sub(r'[إأآا]', 'ا', text)
    
    # Normalize Alif Maqsura -> Ya
    text = text.replace("ى", "ي")
    
    return text


def clean_text(text):
    """Remove punctuation from all languages"""
    # Remove all punctuation including Arabic punctuation
    punctuation = r'[!"#$%&\'()*+,\-./:;<=>?@[\\\]^_`{|}~،؟؛«»؎٭ـ۔]'
    text = re.sub(punctuation, '', text)
    return text.strip()


def get_embedding(text):
    """Get OpenAI embedding for text"""
    if not HAS_AI_DEPS:
        return None
    try:
        response = openai.embeddings.create(
            model="text-embedding-3-large",
            input=text
        )
        return np.array(response.data[0].embedding, dtype=np.float32)
    except Exception as e:
        print(f"Error getting embedding: {e}")
        return None


@app.route('/api/search', methods=['POST'])
def search_hadiths():
    if not HAS_AI_DEPS:
        return jsonify({'message': 'Search is currently disabled due to missing dependencies on the server.'}), 503
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        user_id = data.get('user_id')
        query = data.get('query')
        
        if not query:
            return jsonify({'message': 'Missing query'}), 400
        
        # Normalize and clean query
        normalized_query = normalize_arabic_text(query) if any('\u0600' <= c <= '\u06FF' for c in query) else query
        cleaned_query = clean_text(normalized_query)
        
        # Get embedding
        query_embedding = get_embedding(cleaned_query)
        if query_embedding is None:
            return jsonify({'message': 'Failed to generate embedding'}), 500
        
        # Reshape for FAISS (needs 2D array)
        query_vector = query_embedding.reshape(1, -1)
        
        # Search in both indexes
        hadith_ids = set()
        
        # Search Bukhari
        if bukhari_index is not None and bukhari_mapping is not None:
            k = 10  # Top 10 results
            distances, indices = bukhari_index.search(query_vector, k)
            
            for idx in indices[0]:
                if idx < len(bukhari_mapping):
                    hadith_id = bukhari_mapping.iloc[idx]['hadith_id']
                    hadith_ids.add(('bukhari', hadith_id))
        
        # Search Tirmizi
        if tirmizi_index is not None and tirmizi_mapping is not None:
            k = 10  # Top 10 results
            distances, indices = tirmizi_index.search(query_vector, k)
            
            for idx in indices[0]:
                if idx < len(tirmizi_mapping):
                    hadith_id = tirmizi_mapping.iloc[idx]['hadith_id']
                    hadith_ids.add(('tirmizi', hadith_id))
        
        # Fetch hadiths from database
        if not hadith_ids:
            return jsonify({'results': []}), 200
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Build query to fetch hadiths
        hadith_id_list = [h[1] for h in hadith_ids]
        placeholders = ','.join(['%s'] * len(hadith_id_list))
        
        cursor.execute(f"""
            SELECT 
                h.hadith_id,
                h.hadith_number,
                h.hadith_arabic,
                h.hadith_english,
                h.hadith_urdu,
                b.book_name_english,
                c.chapter_number,
                c.chapter_title_english,
                g.grade_type,
                n.narrator_name
            FROM hadiths h
            JOIN hadith_books b ON h.FK_book_id = b.book_id
            JOIN chapters c ON h.FK_chapter_id = c.chapter_id
            LEFT JOIN hadith_grade g ON h.FK_hadith_grade_id = g.grade_id
            LEFT JOIN hadith_narrator n ON h.FK_hadith_narrator_id = n.narrator_id
            WHERE h.hadith_id IN ({placeholders})
        """, hadith_id_list)
        
        hadiths = cursor.fetchall()
        
        # Save search to history
        if user_id:
            cursor.execute(
                "INSERT INTO history (FK_user_id, query_text, created_at) VALUES (%s, %s, %s)",
                (user_id, query, datetime.now())
            )
            conn.commit()
        
        cursor.close()
        conn.close()
        
        # Format results
        results = []
        for h in hadiths:
            results.append({
                'hadith_id': h['hadith_id'],
                'book_name': h['book_name_english'],
                'hadith_number': h['hadith_number'],
                'chapter_number': h['chapter_number'],
                'grade': h['grade_type'] or 'No grade mention'
            })
        
        return jsonify({'results': results}), 200
        
    except Exception as e:
        print(f"Search error: {e}")
        return jsonify({'message': f'Search failed: {str(e)}'}), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    faiss_status = {
        'bukhari_loaded': bukhari_index is not None,
        'tirmizi_loaded': tirmizi_index is not None,
        'bukhari_mapping_loaded': bukhari_mapping is not None,
        'tirmizi_mapping_loaded': tirmizi_mapping is not None
    }
    return jsonify({
        'status': 'ok', 
        'message': 'API is running',
        'faiss_status': faiss_status
    }), 200


if __name__ == '__main__':
    # Run on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)

