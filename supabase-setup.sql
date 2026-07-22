-- ============================================================================
-- SorriAqua Piscinas — schema do catálogo + seed com os dados atuais do site
-- Rode este arquivo inteiro no SQL Editor do Supabase (projeto novo, vazio).
-- ============================================================================

-- ── TABELAS ──────────────────────────────────────────────────────────────

create table brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  label text not null,
  order_index int not null default 0,
  active boolean not null default true
);

create table product_groups (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references categories(id) on delete cascade,
  label text not null,
  order_index int not null default 0
);

create table products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references categories(id) on delete cascade,
  group_id uuid references product_groups(id) on delete set null,
  brand_id uuid references brands(id) on delete set null,
  name text not null,
  description text,
  image_url text,
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  label text not null,
  order_index int not null default 0
);

-- ── SEGURANÇA (RLS) ──────────────────────────────────────────────────────
-- Qualquer visitante pode LER o catálogo (necessário para o site público).
-- Só um usuário autenticado (a conta da sua cliente, criada no Supabase Auth)
-- pode CRIAR, EDITAR ou APAGAR itens (usado pelo painel admin.html).

alter table brands enable row level security;
alter table categories enable row level security;
alter table product_groups enable row level security;
alter table products enable row level security;
alter table product_variants enable row level security;

create policy "public read brands"     on brands           for select using (true);
create policy "public read categories" on categories        for select using (true);
create policy "public read groups"     on product_groups    for select using (true);
create policy "public read products"   on products          for select using (true);
create policy "public read variants"   on product_variants  for select using (true);

create policy "admin write brands"     on brands           for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write categories" on categories        for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write groups"     on product_groups    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write products"   on products          for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write variants"   on product_variants  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ── SEED: MARCAS PARCEIRAS (seção "Marcas parceiras" do site) ───────────

insert into brands (name, logo_url, order_index) values
  ('Nautilus',  'produtos-imgs/marcas/nautilus.png',  1),
  ('Sodramar',  'produtos-imgs/marcas/sodramar.png',  2),
  ('Jacuzzi',   'produtos-imgs/marcas/jacuzzi.png',   3),
  ('Sibrape',   'produtos-imgs/marcas/sibrape.png',   4),
  ('Tholz',     'produtos-imgs/marcas/tholz.png',     5),
  ('LuxPool',   'produtos-imgs/marcas/luxpool.png',   6),
  ('Syllent',   'produtos-imgs/marcas/syllent.png',   7),
  ('Montreal',  'produtos-imgs/marcas/montreal.png',  8),
  ('Brustec',   'produtos-imgs/marcas/brustec.png',   9),
  ('Genco',     'produtos-imgs/marcas/genco.png',     10),
  ('WEG',       'produtos-imgs/marcas/weg.png',       11),
  ('Viva Vida', 'produtos-imgs/marcas/vivavida.png',  12),
  ('Global',    'produtos-imgs/marcas/global.png',    13);

-- ── SEED: CATEGORIAS (abas do catálogo) ─────────────────────────────────

insert into categories (slug, label, order_index) values
  ('quimicos',     'Químicos',      1),
  ('equipamentos', 'Equipamentos',  2),
  ('limpeza',      'Limpeza',       3),
  ('boias',        'Boias e Lazer', 4),
  ('iluminacao',   'Iluminação',    5),
  ('protecao',     'Proteção',      6);

-- ── SEED: GRUPOS (sub-blocos dentro de Químicos) ────────────────────────

insert into product_groups (category_id, label, order_index) values
  ((select id from categories where slug='quimicos'), 'Cloros', 1),
  ((select id from categories where slug='quimicos'), 'Auxiliares de Tratamento', 2),
  ((select id from categories where slug='quimicos'), 'Corretivos de pH e Alcalinidade', 3),
  ((select id from categories where slug='quimicos'), 'Kits de Análise e Teste', 4);

-- ── SEED: PRODUTOS — Cloros ──────────────────────────────────────────────

insert into products (category_id, group_id, brand_id, name, image_url, order_index) values
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Cloros'), (select id from brands where name='Montreal'), 'Hipoclorito de Cálcio Hipoclean', 'produtos-imgs/montreal/image1.png', 1),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Cloros'), (select id from brands where name='Montreal'), 'Hipoclorito de Cálcio Excellence', 'produtos-imgs/montreal/image2.png', 2),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Cloros'), (select id from brands where name='Montreal'), 'Dicloro Light Blue 3 em 1', 'produtos-imgs/montreal/image4.png', 3),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Cloros'), (select id from brands where name='Montreal'), 'Dicloro Multiação 4 em 1', 'produtos-imgs/montreal/image5.png', 4),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Cloros'), (select id from brands where name='Montreal'), 'Dicloro Estabilizado Premium', 'produtos-imgs/montreal/image3.png', 5);

insert into product_variants (product_id, label, order_index) values
  ((select id from products where name='Hipoclorito de Cálcio Hipoclean'), '10 kg', 1),
  ((select id from products where name='Hipoclorito de Cálcio Excellence'), '10 kg', 1),
  ((select id from products where name='Dicloro Light Blue 3 em 1'),  '1 kg', 1),
  ((select id from products where name='Dicloro Light Blue 3 em 1'),  '2,5 kg', 2),
  ((select id from products where name='Dicloro Light Blue 3 em 1'),  '5 kg', 3),
  ((select id from products where name='Dicloro Light Blue 3 em 1'),  '10 kg', 4),
  ((select id from products where name='Dicloro Multiação 4 em 1'),   '1 kg', 1),
  ((select id from products where name='Dicloro Multiação 4 em 1'),   '2,5 kg', 2),
  ((select id from products where name='Dicloro Multiação 4 em 1'),   '5 kg', 3),
  ((select id from products where name='Dicloro Multiação 4 em 1'),   '10 kg', 4),
  ((select id from products where name='Dicloro Estabilizado Premium'), '1 kg', 1),
  ((select id from products where name='Dicloro Estabilizado Premium'), '2,5 kg', 2),
  ((select id from products where name='Dicloro Estabilizado Premium'), '5 kg', 3),
  ((select id from products where name='Dicloro Estabilizado Premium'), '10 kg', 4);

-- ── SEED: PRODUTOS — Auxiliares de Tratamento ───────────────────────────

insert into products (category_id, group_id, brand_id, name, image_url, order_index) values
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Clarificante Ultra Floc', 'produtos-imgs/montreal/image7.png', 1),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Clarificante em Gel Ultra Floc', 'produtos-imgs/montreal/image8.png', 2),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Algicida Choque Montreal', 'produtos-imgs/montreal/image9.png', 3),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Algicida de Manutenção Montreal', 'produtos-imgs/montreal/image10.png', 4),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Genco'), 'Algicida Choque Genco', 'produtos-imgs/genco/image9.jpg', 5),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Genco'), 'Algicida de Manutenção Genco', 'produtos-imgs/genco/image13.jpg', 6),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Limpa Borda', 'produtos-imgs/montreal/image11.png', 7),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Eliminador de Metais 4 em 1', 'produtos-imgs/montreal/image12.png', 8),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Limpa Pedra', 'produtos-imgs/montreal/image13.png', 9),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Sulfato de Alumínio / Decantador', 'produtos-imgs/montreal/image14.png', 10),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Auxiliares de Tratamento'), (select id from brands where name='Montreal'), 'Aqua Boom', 'produtos-imgs/montreal/image24.png', 11);

insert into product_variants (product_id, label, order_index) values
  ((select id from products where name='Clarificante Ultra Floc'), '1 L', 1),
  ((select id from products where name='Clarificante Ultra Floc'), '900 g', 2),
  ((select id from products where name='Clarificante Ultra Floc'), '5 L', 3),
  ((select id from products where name='Clarificante em Gel Ultra Floc'), 'Kit 4 × 200 g', 1),
  ((select id from products where name='Algicida Choque Montreal'), '1 L', 1),
  ((select id from products where name='Algicida Choque Montreal'), '900 g', 2),
  ((select id from products where name='Algicida Choque Montreal'), '5 L', 3),
  ((select id from products where name='Algicida de Manutenção Montreal'), '1 L', 1),
  ((select id from products where name='Algicida de Manutenção Montreal'), '900 g', 2),
  ((select id from products where name='Algicida de Manutenção Montreal'), '5 L', 3),
  ((select id from products where name='Algicida Choque Genco'), '1 L', 1),
  ((select id from products where name='Algicida de Manutenção Genco'), '1 L', 1),
  ((select id from products where name='Limpa Borda'), '1 L', 1),
  ((select id from products where name='Eliminador de Metais 4 em 1'), '1 L', 1),
  ((select id from products where name='Eliminador de Metais 4 em 1'), '5 L', 2),
  ((select id from products where name='Limpa Pedra'), '5 L', 1),
  ((select id from products where name='Sulfato de Alumínio / Decantador'), '2 kg', 1),
  ((select id from products where name='Aqua Boom'), '1,76 kg', 1);

-- ── SEED: PRODUTOS — Corretivos de pH e Alcalinidade ────────────────────

insert into products (category_id, group_id, brand_id, name, image_url, order_index) values
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Corretivos de pH e Alcalinidade'), (select id from brands where name='Montreal'), 'Redutor de pH e Alcalinidade', 'produtos-imgs/montreal/image15.png', 1),
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Corretivos de pH e Alcalinidade'), (select id from brands where name='Montreal'), 'Barrilha pH+', 'produtos-imgs/montreal/image16.png', 2);

insert into product_variants (product_id, label, order_index) values
  ((select id from products where name='Redutor de pH e Alcalinidade'), '1 L', 1),
  ((select id from products where name='Redutor de pH e Alcalinidade'), '5 L', 2),
  ((select id from products where name='Barrilha pH+'), '2 kg', 1),
  ((select id from products where name='Barrilha pH+'), '7 kg', 2);

-- ── SEED: PRODUTOS — Kits de Análise e Teste ────────────────────────────

insert into products (category_id, group_id, brand_id, name, image_url, order_index) values
  ((select id from categories where slug='quimicos'), (select id from product_groups where label='Kits de Análise e Teste'), (select id from brands where name='Montreal'), 'Estojo de Teste pH e Cloro', 'produtos-imgs/montreal/image20.png', 1);

insert into product_variants (product_id, label, order_index) values
  ((select id from products where name='Estojo de Teste pH e Cloro'), 'Kit completo', 1);

-- ── SEED: PRODUTOS — Equipamentos, Limpeza, Boias, Iluminação, Proteção ─
-- (sem grupo e sem marca — cards com foto da loja + descrição corrida)

insert into products (category_id, name, description, image_url, order_index) values
  ((select id from categories where slug='equipamentos'), 'Kit Bomba e Filtro', 'Conjuntos completos para circulação e filtragem. Vários modelos para diferentes volumes de piscina.', 'IMG-web/IMG_5210.JPG.jpeg', 1),
  ((select id from categories where slug='equipamentos'), 'Aquecedores Solar e Gás', 'Sistemas de aquecimento para manter a temperatura ideal, reduzindo custos com energia.', 'IMG-web/IMG_7595.JPEG', 2),
  ((select id from categories where slug='limpeza'), 'Kit Limpeza Completo', 'Escovão, peneira, aspirador e cabo telescópico. Tudo para limpar do zero.', 'IMG-web/IMG_1781.JPG.jpeg', 1),
  ((select id from categories where slug='boias'), 'Boias e Acessórios', 'Boias infláveis coloridas em diversos tamanhos para crianças e adultos.', 'IMG-web/IMG_1518.JPG.jpeg', 1),
  ((select id from categories where slug='iluminacao'), 'Refletor LED RGB', 'Iluminação multicolorida com controle remoto. Transforma qualquer piscina em ambiente encantador.', 'IMG-web/IMG_9626.JPG.jpeg', 1),
  ((select id from categories where slug='protecao'), 'Capa de Proteção', 'Lona resistente sob medida. Bloqueia luz, folhas e insetos enquanto a piscina não está em uso.', 'IMG-web/IMG_9627.JPG.jpeg', 1);

-- ── STORAGE: bucket público para fotos enviadas pelo painel admin ───────

insert into storage.buckets (id, name, public)
values ('catalogo', 'catalogo', true)
on conflict (id) do nothing;

create policy "public read catalogo bucket"
  on storage.objects for select
  using (bucket_id = 'catalogo');

create policy "admin upload catalogo bucket"
  on storage.objects for insert
  with check (bucket_id = 'catalogo' and auth.role() = 'authenticated');

create policy "admin update catalogo bucket"
  on storage.objects for update
  using (bucket_id = 'catalogo' and auth.role() = 'authenticated');

create policy "admin delete catalogo bucket"
  on storage.objects for delete
  using (bucket_id = 'catalogo' and auth.role() = 'authenticated');

-- ============================================================================
-- Fim. Depois de rodar isto com sucesso:
-- 1. Vá em Authentication → Users no painel do Supabase e crie o usuário de
--    login da sua cliente (e-mail + senha) — é essa conta que vai logar em
--    admin.html.
-- 2. Vá em Project Settings → API e copie "Project URL" e a chave "anon public".
-- 3. Me passe as duas para eu conectar o site e o painel admin a este banco.
-- Fotos novas enviadas pelo painel vão para o bucket "catalogo" (já público
-- para leitura); as fotos que já existem na pasta produtos-imgs/ continuam
-- funcionando normalmente pelos caminhos relativos do seed acima.
-- ============================================================================
