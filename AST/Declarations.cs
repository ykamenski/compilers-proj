﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.Remoting;
using NLog.LayoutRenderers;

namespace Proj3Semantics.AST
{
    using IEnv = ISymbolTable<Symbol>;

    public abstract class DeclNode : Node, INamedType
    {
        public string Name { get; set; }
        public Identifier Identifier { get; set; }

        /// <summary>
        /// Each declaration should have a type associated with it
        /// </summary>
        public virtual TypeNode DeclTypeNode
        {
            get { return TypeNode.TypeNodeDeclaration; }
            set { throw new InvalidOperationException(); }
        }

        public DeclNode(Identifier identifier)
        {
            Identifier = identifier;
            Name = identifier.Name;
        }

    }

    public class DeclarationList : Node
    {
        public DeclarationList(Node node)
        {
            DeclNode decl = node as DeclNode;
            if (decl == null) throw new ArgumentNullException(nameof(decl));
            AddChild(decl);
        }
    }

    public class FunctionDecl : DeclNode
    {
        public IEnv Env { get; set; } = null;
        public TypeNode ReturnTypeSpecifier { get; }
        public ParamListNode ParamListNode { get; set; }
        public Block MethodBody { get; set; }

        public FunctionDecl(FunctionDecl fdecl) : base(fdecl.Identifier)
        {
            this.ReturnTypeSpecifier = fdecl.ReturnTypeSpecifier;
            this.ParamListNode = fdecl.ParamListNode;
            this.MethodBody = fdecl.MethodBody;
            PopulateChildren();
        }
        public FunctionDecl(TypeNode returnTypeSpecifier, MethodDeclarator methodDeclarator, Block methodBody) :
            base(methodDeclarator.Identifier)
        {
            this.ReturnTypeSpecifier = returnTypeSpecifier;
            if (methodDeclarator == null) throw new ArgumentNullException(nameof(methodDeclarator));
            ParamListNode = methodDeclarator.ParamListNode;
            this.MethodBody = methodBody;
            PopulateChildren();
        }

        public void PopulateChildren()
        {
            AddChild(ReturnTypeSpecifier);
            if (ParamListNode != null) AddChild(ParamListNode);
            AddChild(MethodBody);
            
        }

    }

    #region ClassDecl
    public enum ModifierType { PUBLIC, STATIC, PRIVATE }
    public enum AccessorType { Public, Private }


    public class Modifiers : Node
    {
        public List<ModifierType> ModifierTokens { get; set; } = new List<ModifierType>();

        public void AddModType(ModifierType type)
        {
            ModifierTokens.Add(type);
        }

        public Modifiers(ModifierType type)
        {
            AddModType(type);
        }

        public void ProcessModifierTokensFor(ITypeHasModifiers node)
        {
            bool accessorWasSet = false;
            node.IsStatic = false;
            node.AccessorType = AccessorType.Private;
            foreach (ModifierType modifier in ModifierTokens)
            {
                if (modifier == ModifierType.PUBLIC || modifier == ModifierType.PRIVATE)
                {
                    if (accessorWasSet)
                    {
                        CompilerErrors.Add(SemanticErrorTypes.InconsistentModifiers, node.Name);
                        break;
                    }
                    accessorWasSet = true;
                    switch (modifier)
                    {
                        case ModifierType.PUBLIC:
                            node.AccessorType = AccessorType.Public;
                            break;
                        case ModifierType.PRIVATE:
                            node.AccessorType = AccessorType.Private;
                            break;
                        default:
                            throw new ArgumentException();
                    }
                }
                else if (modifier == ModifierType.STATIC)
                {
                    node.IsStatic = true;
                }
                else
                {
                    throw new NotImplementedException("Unrecognized modifier type encountered.");
                }
            }
        }
    }

    public class ClassDeclaration : DeclNode, ITypeHasModifiers
    {
        public IEnv Env { get; set; } = null;
        public AccessorType AccessorType { get; set; }
        public bool IsStatic { get; set; }
        public ClassBody ClassBody { get; set; }
        public ClassDeclaration(
            Modifiers modifiers,
            Identifier identifier,
            ClassBody classBody) : base(identifier)
        {
            // fill in modifier fields for the interface ITypeHasModifiers
            modifiers.ProcessModifierTokensFor(this);
            ClassBody = classBody;

            AddChild(modifiers);
            AddChild(ClassBody);
        }

    }

    public class ClassMethodDecl : FunctionDecl, ITypeHasModifiers
    {
        public AccessorType AccessorType { get; set; }
        public bool IsStatic { get; set; }

        public ClassMethodDecl(Modifiers modifiers, FunctionDecl functionDecl) : base(functionDecl)
        {
            modifiers.ProcessModifierTokensFor(this);
        }
        
        // Method decl is private non-static by default
        public ClassMethodDecl(FunctionDecl functionDecl) : base(functionDecl)
        {
            AccessorType = AccessorType.Private;
            IsStatic = false;
        }
    }

    #endregion






    public class ParamDecl : DeclNode, IEquatable<ParamDecl>
    {
        public override TypeNode DeclTypeNode { get; set; }
        public ParamDecl(TypeNode boundType, Identifier name) : base(name)
        {
            DeclTypeNode = boundType;
            AddChild(boundType);
        }

        public bool Equals(ParamDecl other)
        {
            if (ReferenceEquals(null, other)) return false;
            if (ReferenceEquals(this, other)) return true;
            // only comparing the types for equality
            return Equals(DeclTypeNode, other.DeclTypeNode);
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((ParamDecl)obj);
        }

        public override int GetHashCode()
        {
            return DeclTypeNode.GetHashCode();
        }

        public static bool operator ==(ParamDecl left, ParamDecl right)
        {
            return Equals(left, right);
        }

        public static bool operator !=(ParamDecl left, ParamDecl right)
        {
            return !Equals(left, right);
        }
    }


    public class LocalVarDecl : Node
    {
        public TypeNode TypeSpecifier { get; set; }
        public VarDeclList VarDeclList { get; set; }
        public ExprNode Initialization { get; set; }
        public LocalVarDecl(
            TypeNode typeSpecifier,
            VarDeclList varDeclList,
            Node init = null)
        {

            Debug.Assert(typeSpecifier != null);
            TypeSpecifier = typeSpecifier;

            VarDeclList = varDeclList;
            Debug.Assert(varDeclList != null);

            Initialization = init as ExprNode;

            // adding children for printing
            AddChild(typeSpecifier);
            AddChild(varDeclList);
            if (init != null) AddChild(init);
        }
    }

    public sealed class VarDeclList : Node
    {
        public VarDeclList(VarDecl node)
        {
            AddChild(node);
        }
    }

    public class VarDecl : DeclNode
    {
        public VarDecl(Identifier id) : base(id) { }
        public override TypeNode DeclTypeNode { get; set; } = null;
        public override string ToString()
        {
            return this.DeclTypeNode.ToString();
        }
    }

}
