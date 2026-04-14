import unittest
import os

class VeluraCoreTests(unittest.TestCase):
    def test_environment_variables(self):
        """Vérifie que les variables critiques sont chargées."""
        self.assertIsNotNone(os.environ.get("DATABASE_URL"), "DATABASE_URL manquante")
        self.assertIsNotNone(os.environ.get("SECRET_KEY"), "SECRET_KEY manquante")

    def test_logic_placeholder(self):
        """Test basique pour valider le pipeline."""
        self.assertTrue(1 + 1 == 2)

if __name__ == "__main__":
    unittest.main()