import requests
import argparse

# Parse command line arguments
parser = argparse.ArgumentParser(description="Music Generation Client")
parser.add_argument(
    "--server_url", type=str, default="http://localhost:8000", help="URL of the server"
)
parser.add_argument(
    "--prompts",
    nargs="+",
    type=str,
    default=["Lofi Music for Coding"],
    help="Prompts for music generation",
)
parser.add_argument(
    "--output_file", type=str, default="output.wav", help="Output file name"
)
parser.add_argument(
    "--duration", type=int, default=10, help="Duration of generated music in seconds"
)
parser.add_argument(
    "--check_health", action='store_true', help="Check server health"
)

args = parser.parse_args()

def generate_music(server_url, prompts, duration, output_file):
    url = f"{server_url}/generate_music"
    headers = {"Content-Type": "application/json"}
    data = {"prompts": prompts, "duration": duration}

    response = requests.get(url, json=data, headers=headers)

    if response.status_code == 200:
        with open(output_file, "wb") as f:
            f.write(response.content)
        print(f"Music saved to {output_file}")
    else:
        print(f"Failed to generate music: {response.status_code}, {response.text}")

def check_server_health(server_url):
    url = f"{server_url}/health"
    response = requests.get(url)
    
    if response.status_code == 200:
        health_status = response.json()
        print("Server Health Check:")
        print(f"Server Running: {health_status['server_running']}")
        print(f"Model Loaded: {health_status['model_loaded']}")
        print(f"CPU Usage: {health_status['cpu_usage_percent']}%")
        print(f"RAM Usage: {health_status['ram_usage_percent']}%")
        if 'gpu_memory_allocated' in health_status:
            gpu_memory_allocated_gb = health_status['gpu_memory_allocated'] / (1024 ** 3)
            gpu_memory_reserved_gb = health_status['gpu_memory_reserved'] / (1024 ** 3)
            print(f"GPU Memory Allocated: {gpu_memory_allocated_gb:.2f} GB")
            print(f"GPU Memory Reserved: {gpu_memory_reserved_gb:.2f} GB")
    else:
        print(f"Failed to check server health: {response.status_code}, {response.text}")

if __name__ == "__main__":
    if args.check_health:
        check_server_health(args.server_url)
    else:
        generate_music(args.server_url, args.prompts, args.duration, args.output_file)
