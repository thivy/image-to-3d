from fastapi import FastAPI, UploadFile, File
from PIL import Image
import io
import os
from trellis.pipelines import TrellisImageTo3DPipeline
from trellis.utils import render_utils, postprocessing_utils

app = FastAPI()

# Load the TRELLIS pipeline model
pipeline = TrellisImageTo3DPipeline.from_pretrained("JeffreyXiang/TRELLIS-image-large")
pipeline.cuda()

@app.post("/generate")
async def generate_3d_asset(file: UploadFile = File(...)):
    # Load the uploaded image
    image = Image.open(io.BytesIO(await file.read()))
    
    # Run the pipeline
    outputs = pipeline.run(image, seed=1)
    
    # Prepare the response
    response = {
        "gaussian": outputs['gaussian'],
        "radiance_field": outputs['radiance_field'],
        "mesh": outputs['mesh']
    }
    return response

@app.get("/")
async def read_root():
    return {"message": "Welcome to the TRELLIS 3D Generation API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)