from fastapi import FastAPI, HTTPExcepetion
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import pickle 
import joblib
import numpy as np
from typing import List


#1. Load Model dan Scaler
try:
    with open('model.pkl', 'rb') as f:
        model = pickle.load(f)
    scaler = joblib.load('scaler.pkl')
    print("Model dan Scaler berhasil di load")
except Exception as e:
    print(f"Gagal load model atau scaler: {e}")
    model = None
    scaler = None
    
#2. Define Input Scheme (Pydantic Model)
class F1Features(BaseModel):
    features : List[float]
    
#3. Inisialisasi FastAPI App
app = FastAPI(title = " F1 Winner Predictior API")

#4. Add Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#5. HC Endpoint
@app.get("/")
def home() :
    return {"status": "ready", "model_loaded" : model is not None, "message": "F1 API Running " }

#6. Prediction Endpoint
@app.post("/predict")
def predict(data: F1Features):
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail= "Server Error : Model/Scaler tidak dapat dimuat")
    
    input_array = np.array(data.feaetures).reshape(1, -1)
    
    #Validasi jumlah fitur
    if input_array.shape[1] != 19:
        raise HTTPException(status_code=400, detail=f"Jumlah fitur salah. Diharapkan 19, diterima {input_array.shape[1]}")
    
    #Scalling input
    input_scaled = scaler.transform(input_array)
    
    #prediksi (Ambil probabilitas kelas 1)
    probability = model.predict_proba(input_scaled)[:, 1].item()
    
    return {"winner_probability": probability}