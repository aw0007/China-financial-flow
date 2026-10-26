import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt


# Load the Excel file
file_path = "C:/Users/massa/Desktop/Repli/data/IGRAPHDATA2.xlsx"
data = pd.read_excel(file_path)

# Calculer les poids des arêtes comme valeurs normalisées de 'stream'
data['weight'] = data['stream'] / data['stream'].max()

# Calculer la taille totale reçue par chaque cible pour les tailles de nœuds
node_size = data.groupby('target')['stream'].sum()
node_size = 1000 * (node_size / node_size.max())  # Normaliser pour la visualisation

# Créer un graphe dirigé
G = nx.DiGraph()

# Ajouter des nœuds avec les données de taille
for node in set(data['target'].unique()).union(set(data['source'].unique())):  # Ajoute tous les nœuds possibles
    G.add_node(node, size=node_size.get(node, 100))  # Utilise une taille par défaut si non spécifiée

# Ajouter des arêtes avec les données de poids
for _, row in data.iterrows():
    G.add_edge(row['source'], row['target'], weight=row['weight'])

# Définir les positions des nœuds en utilisant le layout 'spring'
pos = nx.spring_layout(G)

# Dessiner le graphe
plt.figure(figsize=(12, 13))
nx.draw_networkx_nodes(G, pos, node_size=[G.nodes[node]['size'] for node in G], node_color='skyblue', alpha=0.7)
nx.draw_networkx_edges(G, pos, edge_color='grey', width=[G[u][v]['weight']*5 for u, v in G.edges()], alpha=0.99)
nx.draw_networkx_labels(G, pos, font_size=9, font_family='sans-serif')

plt.axis('off')
plt.savefig('C:/Users/massa/Desktop/Repli/resultats/network_graph.png')
plt.show()


# Calculer la taille totale reçue par chaque cible pour les tailles de nœuds
node_size = data.groupby('target')['stream'].sum()
node_size_normalized = 1000 * (node_size / node_size.max())  # Normaliser pour la visualisation

# Créer un graphe dirigé
G = nx.DiGraph()

# Ajouter des nœuds avec les données de taille
for node in set(data['target'].unique()).union(set(data['source'].unique())):
    G.add_node(node, size=node_size_normalized.get(node, 100), total_stream=node_size.get(node, 0))

# Ajouter des arêtes avec les données de poids
for _, row in data.iterrows():
    G.add_edge(row['source'], row['target'], weight=row['weight'])

# Calcul initial des positions avec spring_layout
pos = nx.spring_layout(G)

# Ajustement des positions pour rapprocher les nœuds importants du centre
for node in pos:
    # Rapprocher les nœuds du centre en fonction du flux total qu'ils reçoivent
    factor = node_size.get(node, 0) / node_size.max()
    pos[node] *= (1 - factor)  # Réduire la distance du centre proportionnellement au facteur

# Dessiner le graphe
plt.figure(figsize=(10, 10))
nx.draw_networkx_nodes(G, pos, node_size=[G.nodes[node]['size'] for node in G], node_color='skyblue', alpha=0.6)
nx.draw_networkx_edges(G, pos, edge_color='grey', width=[G[u][v]['weight']*5 for u, v in G.edges()], alpha=0.8)
nx.draw_networkx_labels(G, pos, font_size=10, font_family='sans-serif')

plt.axis('off')
plt.savefig('C:/Users/massa/Desktop/Repli/resultats/network_graph_adjusted.png')  # Enregistrer l'image
plt.show()