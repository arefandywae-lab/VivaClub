import random

ADJECTIVES = [
    "Happy", "Sad", "Sleepy", "Brave", "Calm", "Gentle", "Wild", "Clever",
    "Quiet", "Loud", "Lucky", "Grumpy", "Jolly", "Kind", "Proud", "Humble",
    "Eager", "Lazy", "Busy", "Dizzy", "Fuzzy", "Shiny", "Misty", "Sunny"
]

ANIMALS = [
    "Panda", "Eagle", "Lion", "Tiger", "Bear", "Wolf", "Fox", "Rabbit",
    "Koala", "Sloth", "Otter", "Penguin", "Owl", "Hawk", "Deer", "Elephant",
    "Giraffe", "Zebra", "Monkey", "Cat", "Dog", "Whale", "Dolphin", "Shark"
]

def generate_ghost_name():
    """Generates a random name: Adjective + Animal + Number"""
    adj = random.choice(ADJECTIVES)
    animal = random.choice(ANIMALS)
    number = random.randint(10, 999)
    return f"{adj} {animal} #{number}"
