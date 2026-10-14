from fastapi import FastAPI, Query, HTTPException
from pydantic import BaseModel
import pandas as pd
import mysql.connector
import os
from typing import List, Optional

app = FastAPI(title="Boarding House Analytics Service")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "boarding_house_db"),
    "port": int(os.getenv("DB_PORT", 3306))
}

class OccupancyTrendResponse(BaseModel):
    month: str
    occupancy_rate: float

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

@app.get("/api/analytics/occupancy-trend", response_model=List[OccupancyTrendResponse])
def get_occupancy_trend(
    kost_id: Optional[int] = Query(None, description="ID Kos"),
    year: int = Query(..., description="Tahun analisis")
):
    try:
        conn = get_db_connection()
        query_kost = "SELECT id, total_kamar FROM kosts"
        if kost_id:
            query_kost += f" WHERE id = {kost_id}"
        df_kost = pd.read_sql(query_kost, conn)
        
        if df_kost.empty:
            return []

        total_capacity = df_kost['total_kamar'].sum()

        query_trans = f"""
            SELECT t.bulan, t.tahun, p.kamar_id 
            FROM transaksis t
            JOIN penghunis p ON t.penghuni_id = p.id
            JOIN kamars km ON p.kamar_id = km.id
            WHERE t.tahun = {year}
        """
        if kost_id:
            query_trans += f" AND km.kost_id = {kost_id}"
            
        df_trans = pd.read_sql(query_trans, conn)
        conn.close()

        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        result = []

        for m_idx, m_name in enumerate(months, start=1):
            if df_trans.empty:
                occupancy_rate = 0.0
            else:
                occupied_rooms = df_trans[df_trans['bulan'] == m_idx]['kamar_id'].nunique()
                occupancy_rate = round((occupied_rooms / total_capacity) * 100, 2) if total_capacity > 0 else 0.0

            result.append({
                "month": m_name,
                "occupancy_rate": occupancy_rate
            })

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengolah data analytics: {str(e)}")