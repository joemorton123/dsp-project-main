import os
from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

def train_agent():
<<<<<<< HEAD
    print(" Waiting for Godot... Please press PLAY in the Godot Editor now!")
    
    env = StableBaselinesGodotEnv(env_path=None, show_window=True)
    print(" Connected to Godot!")

    # Load the V2 brain so we don't lose our 1 Million steps of progress!
    print(" Loading the V2 Self-Play Brain to continue training...")
    model = PPO.load("brawler_self_play_v2", env=env)

    print(" Resuming Self-Play! Watch them evolve to Level 3...")
=======
    print("🤖 Waiting for Godot... Please press PLAY in the Godot Editor now!")
    
    env = StableBaselinesGodotEnv(env_path=None, show_window=True)
    print("✅ Connected to Godot!")

    # Load the V2 brain so we don't lose our 1 Million steps of progress!
    print("🧠 Loading the V2 Self-Play Brain to continue training...")
    model = PPO.load("brawler_self_play_v2", env=env)

    print("🚀 Resuming Self-Play! Watch them evolve to Level 3...")
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2
    # Train for ANOTHER 1 Million steps
    model.learn(total_timesteps=1000000) 

    # Save the even smarter brain as V3
<<<<<<< HEAD
    print(" Training Complete! Saving the new V3 AI model...")
    model.save("brawler_self_play_v3")
    
    env.close()
    print(" All done! You can stop the Godot game now.")
=======
    print("💾 Training Complete! Saving the new V3 AI model...")
    model.save("brawler_self_play_v3")
    
    env.close()
    print("🛑 All done! You can stop the Godot game now.")
>>>>>>> dcd3ecb527f85fa55630e7d6f168040239aa5eb2

if __name__ == "__main__":
    train_agent()