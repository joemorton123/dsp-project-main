import os
from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

def train_agent():
    print(" Waiting for Godot... Please press PLAY in the Godot Editor now!")
    
    env = StableBaselinesGodotEnv(env_path=None, show_window=True)
    print(" Connected to Godot!")

    # Load the V4 brain so we don't lose steps of progress!
    print(" Loading the V4 Self-Play Brain to continue training...")
    model = PPO.load("brawler_self_play_v4", env=env)

    print(" Resuming Self-Play! Watch them evolve to Level 4...")
    model.learn(total_timesteps=200000) 

    # Save the even smarter brain as V5
    print(" Training Complete! Saving the new V5 AI model...")
    model.save("brawler_self_play_v5")
    
    env.close()
    print(" All done! You can stop the Godot game now.")

if __name__ == "__main__":
    train_agent()