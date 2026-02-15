import random

ADJECTIVES = [
    "Happy", "Sad", "Sleepy", "Brave", "Calm", "Gentle", "Wild", "Clever",
    "Quiet", "Loud", "Lucky", "Grumpy", "Jolly", "Kind", "Proud", "Humble",
    "Eager", "Lazy", "Busy", "Dizzy", "Fuzzy", "Shiny", "Misty", "Sunny"
]

ANIMALS = [
    # Mammals
    "Panda", "Bear", "Polar Bear", "Koala", "Tiger", "Lion", "Leopard", "Cheetah", 
    "Wolf", "Fox", "Raccoon", "Cat", "Dog", "Poodle", "Mouse", "Rat", "Hamster", 
    "Rabbit", "Otter", "Badger", "Bat", "Hedgehog", "Squirrel", "Chipmunk", 
    "Beaver", "Sloth", "Cow", "Ox", "Buffalo", "Bull", "Pig", "Boar", "Sheep", 
    "Ram", "Goat", "Llama", "Alpaca", "Camel", "Giraffe", "Elephant", "Rhino", 
    "Hippo", "Mammoth", "Gorilla", "Orangutan", "Monkey", "Chimp", "Baboon", 
    "Lemur", "Horse", "Donkey", "Mule", "Zebra", "Deer", "Antelope", "Kangaroo", 
    "Platypus", "Skunk", "Mole", "Dormouse", "Meerkat", "Groundhog", "Porcupine",
    "Moose", "Elk", "Okapi", "Tapir", "Wombat", "Quokka", "Wallaby", "Dingo",

    # Birds
    "Eagle", "Hawk", "Falcon", "Owl", "Parrot", "Flamingo", "Peacock", "Swan", 
    "Dove", "Pigeon", "Duck", "Goose", "Chicken", "Rooster", "Turkey", "Quail", 
    "Penguin", "Stork", "Toucan", "Dodo", "Phoenix", "Sparrow", "Crow", "Blue Jay", 
    "Robin", "Cardinal", "Canary", "Hummingbird", "Woodpecker", "Seagull", "Pelican", 
    "Kingfisher", "Heron", "Crane", "Ostrich", "Emu", "Kiwi",

    # Reptiles & Amphibians
    "Turtle", "Tortoise", "Crocodile", "Alligator", "Snake", "Python", "Viper", 
    "Cobra", "Lizard", "Iguana", "Gecko", "Chameleon", "Dragon", "Dinosaur", "Rex", 
    "Sauropod", "Triceratops", "Pterodactyl", "Frog", "Toad", "Newt", "Salamander", "Axolotl",

    # Marine
    "Whale", "Dolphin", "Porpoise", "Seal", "Walrus", "Manatee", "Shark", "Orca",
    "Fish", "Blowfish", "Pufferfish", "Tuna", "Salmon", "Carp", "Clownfish",
    "Seahorse", "Octopus", "Squid", "Jellyfish", "Crab", "Lobster", "Shrimp", 
    "Prawn", "Oyster", "Clam", "Snail", "Slug", "Shell", "Coral", "Starfish", "Ray",

    # Bugs
    "Bee", "Wasp", "Hornet", "Bumblebee", "Butterfly", "Moth", "Ladybug", "Beetle", 
    "Cockroach", "Cricket", "Grasshopper", "Cicada", "Ant", "Termite", "Dragonfly", 
    "Mosquito", "Fly", "Worm", "Centipede", "Millipede", "Spider", "Tarantula", 
    "Scorpion", "Louse", "Flea", "Tick", "Mantis", "Stick Bug",

    # Mythical & Others
    "Unicorn", "Pegasus", "Kraken", "Yeti", "Bigfoot", "Dragon", "Ghost", "Alien", 
    "Robot", "Monster", "Genie", "Fairy", "Vampire", "Mermaid", "Elf", "Zombie", 
    "Mummy", "Skeleton", "Brain", "Heart", "Eye", "Tooth", "Bone", "Microbe", 
    "Virus", "Bacteria", "Amoeba", "DNA"
]

def generate_ghost_name():
    """Generates a random name: Adjective + Animal + Number"""
    adj = random.choice(ADJECTIVES)
    animal = random.choice(ANIMALS)
    number = random.randint(10, 999)
    return f"{adj} {animal} #{number}"
