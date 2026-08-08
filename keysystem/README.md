# lizard — système de licences (clés liées au UserId)

Le script principal n'est **plus sur le GitHub public** : il est stocké **côté serveur (Supabase)** et
n'est renvoyé qu'à une licence valide. Un utilisateur qui lit le loader ne peut rien en tirer.

```
User entre sa clé  →  loader (GitHub public, petit)  →  Supabase vérifie clé + UserId + expiration
                                                              ↓ (valide)
                                              renvoie le script obfusqué → loadstring → exécution
```

## 1. Créer le projet Supabase (gratuit, sans carte bancaire)

1. Va sur https://supabase.com et crée un compte.
2. `New project` → choisis une région (proche de toi) et un mot de passe de base de données.
3. Une fois créé, tu as besoin de 3 choses (menu ⚙️ → **Project Settings → API**):
   - **Project URL** : ex. `https://abcdefgh.supabase.co`
   - **anon / public key** → va dans le **loader** (`lizard_loader.lua`)
   - **service_role key** → va dans **admin.html** (secret, à garder pour toi)

## 2. Installer les tables + la fonction de validation

Dans Supabase → **SQL Editor** → `New query` → colle tout le contenu de `supabase_setup.sql` → **Run**.

## 3. Stocker ton script obfusqué

Ouvre `admin.html` dans ton navigateur (double-clic, ou héberge-la quelque part de privé).

1. Colle l'URL du projet + la **service_role key** → clique **Charger**.
2. Obturce ton script avant : MoonSec V2, Ironbrew, Ruben's… (obligatoire, sinon n'importe quel
   utilisateur licencié peut extraire le code depuis sa RAM/`getsenv`).
3. Onglet **"Code source du script"** → colle le script obfusqué → **Enregistrer**.
   (En attendant, tu peux mettre le brut : ça marche, mais moins sûr.)

## 4. Configurer le loader

Dans `lizard_loader.lua`, remplace les 2 lignes du haut :
```lua
local SUPABASE_URL = "https://abcdefgh.supabase.co"
local ANON_KEY     = "eyJhbGciOi..."
```
Puis **obfusque aussi ce loader** et uploade-le sur ton repo GitHub à la place de `lizard.lua`.

## 5. Créer des licences

Dans `admin.html` :
- **Créer une licence** → rentre le **UserId** du client (trouvable via https://www.roblox.com/users/1
  → le UserId est dans l'URL, ou via n'importe quel outil), durée en jours (0 = illimité), une note.
- La clé générée s'affiche → tu la donnes au client.
- **Révoquer** supprime une licence ; la personne ne pourra plus charger le script.

## 6. Les utilisateurs

Ils exécutent comme avant :
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/hahaahahahhahahahah/lizard/main/lizard.lua"))()
```
Ils entrent leur clé → si le UserId correspond et que la licence n'est pas expirée, le script charge.

## Notes de sécurité
- La **service_role key** ne doit JAMAIS aller dans le script — uniquement dans admin.html.
- Le GitHub reste public mais ne contient que le loader (obfusqué) : le vrai code n'y est pas.
- L'obfuscation du script principal protège contre l'extraction par des utilisateurs licenciés.
- Les clés sont liées au UserId : partager sa clé à un autre compte ne fonctionne pas.
