# Meu fluxo de caixa — como colocar no ar

Você vai fazer duas coisas: criar o banco de dados (Supabase) e publicar o site (GitHub).
Faça o Supabase primeiro, porque você vai precisar de duas chaves dele.

---

## PARTE 1 — Supabase (o banco de dados)

### 1. Crie a conta e o projeto
- Acesse supabase.com e crie uma conta gratuita.
- Clique em **New project**.
- Dê um nome (ex: `fluxo-caixa`), defina uma senha de banco (guarde num lugar seguro) e escolha a região **South America (São Paulo)**.
- Espere uns 2 minutos até o projeto ficar pronto.

### 2. Crie a tabela
- No menu lateral, clique em **SQL Editor** > **New query**.
- Cole o código abaixo inteiro e clique em **Run**:

```sql
create table transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  description text,
  category text,
  type text,
  amount numeric not null,
  created_at timestamptz default now()
);

alter table transactions enable row level security;

create policy "cada um ve so o seu"
  on transactions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index on transactions (user_id, date);
```

Isso cria a tabela e garante que **só você** enxerga os seus lançamentos.

### 3. Pegue suas chaves
- Vá em **Project Settings** (engrenagem) > **API**.
- Copie o **Project URL** e a chave **anon public**.
- Abra o arquivo `index.html` e substitua no topo do script:

```js
const SUPABASE_URL  = 'COLE_AQUI_SUA_PROJECT_URL';
const SUPABASE_ANON = 'COLE_AQUI_SUA_ANON_PUBLIC_KEY';
```

> A chave `anon` é pública por natureza — pode ficar no GitHub sem problema.
> Quem protege seus dados é a política de segurança (RLS) que você criou no passo 2.

---

## PARTE 2 — GitHub (publicar o site)

### 1. Crie o repositório
- Acesse github.com e crie uma conta, se ainda não tiver.
- Clique em **New repository**.
- Nome: `fluxo-caixa`. Marque **Public**. Crie.

### 2. Suba os arquivos
- Na tela do repositório, clique em **uploading an existing file**.
- Arraste os 4 arquivos: `index.html`, `manifest.json`, `icone.png` e `LEIA-ME.md`.
- Clique em **Commit changes**.

### 3. Ligue o GitHub Pages
- No repositório, vá em **Settings** > **Pages**.
- Em *Source*, escolha **Deploy from a branch**.
- Em *Branch*, escolha **main** e a pasta **/ (root)**. Salve.
- Espere 1-2 minutos. O endereço aparece no topo da página, assim:

```
https://SEUUSUARIO.github.io/fluxo-caixa/
```

### 4. Avise o Supabase sobre esse endereço
- Volte no Supabase > **Authentication** > **URL Configuration**.
- Em **Site URL**, coloque o endereço do GitHub Pages.
- Em **Redirect URLs**, adicione o mesmo endereço.
- Salve. (Sem isso o link de login por e-mail não funciona.)

---

## PARTE 3 — Instalar no celular

1. Abra o endereço `https://SEUUSUARIO.github.io/fluxo-caixa/` no Chrome do Android.
2. Digite seu e-mail e clique em **Receber link de acesso**.
3. Abra o e-mail que chegou e clique no link — você entra sem senha.
4. Com o sistema aberto, toque nos **três pontinhos** (⋮) > **Instalar app** (ou *Adicionar à tela inicial*).

Agora existe um ícone na sua tela que abre o sistema direto, em tela cheia, sem passar por lugar nenhum.
E como os dados estão no Supabase, você acessa do celular ou do computador e vê sempre a mesma coisa.

---

## Observações

- **Primeiro acesso:** o sistema começa vazio. Se você tem um backup `.json` do sistema anterior, entre e use o botão **Importar backup** para trazer tudo.
- **Backup continua funcionando:** o botão de baixar backup segue ali. Vale usar de vez em quando, mesmo com o banco na nuvem.
- **Plano gratuito do Supabase:** projetos sem acesso por cerca de uma semana entram em pausa. Como você vai usar toda semana, isso não deve acontecer — mas se acontecer, é só entrar no painel do Supabase e clicar em *Restore*.
- **Para mudar alguma coisa depois** (categoria nova, cor, etc.): edite o `index.html` direto pelo GitHub, pelo ícone de lápis. O site atualiza sozinho em 1-2 minutos.
