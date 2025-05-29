-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid REFERENCES auth.users ON DELETE CASCADE,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  role text NOT NULL CHECK (role IN ('Professor', 'Aluno', 'Área Técnica', 'Administração')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,

  PRIMARY KEY (id)
);

-- Create a secure policy
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Função auxiliar para verificar se o usuário é administrador
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN (
    SELECT role = 'Administração'
    FROM users
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Políticas atualizadas para incluir verificação de administrador
CREATE POLICY "Users are viewable by authenticated users" 
  ON users FOR SELECT 
  TO authenticated 
  USING (true);

CREATE POLICY "Users can be created by administrators" 
  ON users FOR INSERT 
  TO authenticated 
  WITH CHECK (is_admin());

CREATE POLICY "Users can be updated by administrators" 
  ON users FOR UPDATE 
  TO authenticated 
  USING (is_admin());

CREATE POLICY "Users can be deleted by administrators" 
  ON users FOR DELETE 
  TO authenticated 
  USING (is_admin());

-- Create a trigger to automatically create a user record when a new auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, name, email, role)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'name',
    new.email,
    COALESCE(new.raw_user_meta_data->>'role', 'Aluno')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 