import numpy as np
import os

def generate_data():
    # Features: [standingsDiff, goalsDiff, homeAdvantage, homeGoals, awayGoals]
    # standingsDiff = homePos - awayPos (range -19 to 19)
    # goalsDiff = homeGoals - awayGoals (range -5 to 5)
    # homeAdvantage = 1.0 or 0.0
    # homeGoals = average goals for home team (0 to 5)
    # awayGoals = average goals for away team (0 to 5)
    
    np.random.seed(42)
    num_samples = 2000
    
    X = []
    y = [] # 3 classes: [win, draw, loss]
    
    for _ in range(num_samples):
        std_diff = np.random.uniform(-15, 15)
        gl_diff = np.random.uniform(-3, 3)
        h_adv = np.random.choice([0.0, 1.0])
        h_gl = np.random.uniform(0.5, 4.0)
        a_gl = np.random.uniform(0.5, 4.0)
        
        # Calculate winning logits
        # Negative std_diff means home team is higher placed (better rank) -> higher win probability
        # Positive gl_diff means home team scores more -> higher win probability
        win_logit = -0.15 * std_diff + 0.6 * gl_diff + 0.4 * h_adv + 0.3 * (h_gl - a_gl)
        loss_logit = 0.15 * std_diff - 0.6 * gl_diff - 0.4 * h_adv + 0.3 * (a_gl - h_gl)
        draw_logit = 0.1 # Constant base for draw
        
        logits = np.array([win_logit, draw_logit, loss_logit])
        probs = np.exp(logits) / np.sum(np.exp(logits))
        
        X.append([std_diff, gl_diff, h_adv, h_gl / 5.0, a_gl / 5.0]) # Normalize goal features like in Flutter
        y.append(probs)
        
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)

def main():
    print("Checking if TensorFlow is available...")
    try:
        import tensorflow as tf
    except ImportError:
        print("TensorFlow is not installed. Installing tensorflow-cpu...")
        import subprocess
        import sys
        # Run pip install tensorflow-cpu
        subprocess.check_call([sys.executable, "-m", "pip", "install", "tensorflow-cpu", "--quiet"])
        import tensorflow as tf
        
    print("TensorFlow version:", tf.__version__)
    
    X, y = generate_data()
    print(f"Generated {X.shape[0]} training sample pairs.")
    
    # Define Neural Network
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(5,)),
        tf.keras.layers.Dense(8, activation='relu'),
        tf.keras.layers.Dense(8, activation='relu'),
        tf.keras.layers.Dense(3, activation='softmax')
    ])
    
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    
    print("Training neural network...")
    model.fit(X, y, epochs=15, batch_size=32, verbose=1)
    
    print("Converting model to TensorFlow Lite format...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    output_path = os.path.join("assets", "model", "match_predictor.tflite")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, "wb") as f:
        f.write(tflite_model)
        
    print(f"Successfully saved TFLite model to {output_path} ({len(tflite_model)} bytes)")

if __name__ == "__main__":
    main()
