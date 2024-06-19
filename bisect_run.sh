#!/bin/bash

# Timeout en secondes (5 minutes)
TIMEOUT=300

# Commande à exécuter
CMD="bundle exec ./bin/rspec --seed 6227 -f d"

# Fonction pour tester si le commit est bon ou mauvais
bisect_run() {
    # Exécuter la commande avec un timeout
    timeout $TIMEOUT $CMD
    RESULT=$?

    if [ $RESULT -eq 124 ]; then
        # Timeout, considérer comme un échec
        return 1
    elif [ $RESULT -eq 0 ]; then
        # Succès, considérer comme un bon commit
        return 0
    else
        # Échec pour une autre raison, considérer comme un échec
        return 1
    fi
}

bisect_run
