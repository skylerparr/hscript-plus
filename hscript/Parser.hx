/*
 * Copyright (c) 2008, Nicolas Cannasse
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package hscript;
import hscript.Expr;

enum Token {
	TEof;
	TConst( c : Const );
	TId( s : String );
	TOp( s : String );
	TPOpen;
	TPClose;
	TBrOpen;
	TBrClose;
	TDot;
	TComma;
	TSemicolon;
	TBkOpen;
	TBkClose;
	TQuestion;
	TDoubleDot;
}

class Parser {

	// config / variables
	public var line : Int;
	public var opChars : String;
	public var identChars : String;
	public var opPriority : Array<String>;
	public var unopsPrefix : Array<String>;
	public var unopsSuffix : Array<String>;

	// implementation
	var char : Null<Int>;
	var ops : Array<Bool>;
	var idents : Array<Bool>;
	var tokens : haxe.FastList<Token>;

	public function new() {
		line = 1;
		opChars = "+*/-=!><&|^%~";
		identChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
		opPriority = [
			"...",
			"=",
			"||","&&",
			"==","!=",">","<",">=","<=",
			"|","&","^",
			"<<",">>",">>>",
			"+","-",
			"*","/",
			"%"
		];
		unopsPrefix = ["!","++","--","-","~"];
		unopsSuffix = ["++","--"];
	}

	public function parseString( s : String ) {
		line = 1;
		return parse( new haxe.io.StringInput(s) );
	}

	public function parse( s : haxe.io.Input ) {
		char = null;
		ops = new Array();
		idents = new Array();
		tokens = new haxe.FastList<Token>();
		for( i in 0...opChars.length )
			ops[opChars.charCodeAt(i)] = true;
		for( i in 0...identChars.length )
			idents[identChars.charCodeAt(i)] = true;
		var a = new Array();
		while( true ) {
			var tk = token(s);
			if( tk == TEof ) break;
			tokens.add(tk);
			a.push(parseFullExpr(s));
		}
		return if( a.length == 1 ) a[0] else EBlock(a);
	}

	function unexpected( tk ) : Dynamic {
		throw Error.EUnexpected(tokenString(tk));
		return null;
	}

	function isBlock(e) {
		return switch( e ) {
		case EBlock(_): true;
		case EFunction(_,e,_): isBlock(e);
		case EVar(_,e): e != null && isBlock(e);
		case EIf(_,e1,e2): if( e2 != null ) isBlock(e2) else isBlock(e1);
		case EBinop(_,_,e): isBlock(e);
		case EUnop(_,prefix,e): !prefix && isBlock(e);
		case EWhile(_,e): isBlock(e);
		case EFor(_,_,e): isBlock(e);
		case EReturn(e): e != null && isBlock(e);
		default: false;
		}
	}

	function parseFullExpr(s) {
		var e = parseExpr(s);
		var tk = token(s);
		if( tk != TSemicolon && tk != TEof ) {
			if( isBlock(e) )
				tokens.add(tk);
			else
				unexpected(tk);
		}
		return e;
	}

	function parseExpr( s : haxe.io.Input ) {
		var tk = token(s);
		switch( tk ) {
		case TId(id):
			var e = parseStructure(s,id);
			if( e == null )
				e = EIdent(id);
			return parseExprNext(s,e);
		case TConst(c):
			return parseExprNext(s,EConst(c));
		case TPOpen:
			var e = parseExpr(s);
			tk = token(s);
			if( tk != TPClose ) unexpected(tk);
			return parseExprNext(s,EParent(e));
		case TBrOpen:
			var a = new Array();
			while( true ) {
				tk = token(s);
				if( tk == TBrClose )
					break;
				tokens.add(tk);
				a.push(parseFullExpr(s));
			}
			return EBlock(a);
		case TOp(op):
			var found;
			for( x in unopsPrefix )
				if( x == op )
					return makeUnop(op,parseExpr(s));
			return unexpected(tk);
		case TBkOpen:
			return parseExprNext(s,EArrayDecl(parseExprList(s,TBkClose)));
		default:
			return unexpected(tk);
		}
	}

	function priority(op) {
		for( i in 0...opPriority.length )
			if( opPriority[i] == op )
				return i;
		return -1;
	}

	function makeUnop( op, e ) {
		return switch( e ) {
		case EBinop(bop,e1,e2): EBinop(bop,makeUnop(op,e1),e2);
		default: EUnop(op,true,e);
		}
	}

	function makeBinop( op, e1, e ) {
		return switch( e ) {
		case EBinop(op2,e2,e3):
			if( priority(op) > priority(op2) )
				EBinop(op2,makeBinop(op,e1,e2),e3);
			else
				EBinop(op,e1,e);
		default: EBinop(op,e1,e);
		}
	}

	function parseStructure( s, id ) {
		return switch( id ) {
		case "if":
			var cond = parseExpr(s);
			var e1 = parseExpr(s);
			var e2 = null;
			var semic = false;
			var tk = token(s);
			if( tk == TSemicolon ) {
				semic = true;
				tk = token(s);
			}
			if( Type.enumEq(tk,TId("else")) )
				e2 = parseExpr(s);
			else {
				tokens.add(tk);
				if( semic ) tokens.add(TSemicolon);
			}
			EIf(cond,e1,e2);
		case "var":
			var tk = token(s);
			var ident = null;
			switch(tk) {
			case TId(id): ident = id;
			default: unexpected(tk);
			}
			tk = token(s);
			var e = null;
			if( Type.enumEq(tk,TOp("=")) )
				e = parseExpr(s);
			else
				tokens.add(tk);
			EVar(ident,e);
		case "while":
			var econd = parseExpr(s);
			var e = parseExpr(s);
			EWhile(econd,e);
		case "for":
			var tk = token(s);
			if( tk != TPOpen ) unexpected(tk);
			tk = token(s);
			var vname = null;
			switch( tk ) {
			case TId(id): vname = id;
			default: unexpected(tk);
			}
			tk = token(s);
			if( !Type.enumEq(tk,TId("in")) ) unexpected(tk);
			var eiter = parseExpr(s);
			tk = token(s);
			if( tk != TPClose ) unexpected(tk);
			EFor(vname,eiter,parseExpr(s));
		case "break": EBreak;
		case "continue": EContinue;
		case "else": unexpected(TId(id));
		case "function":
			var tk = token(s);
			var name = null;
			switch( tk ) {
			case TId(id): name = id; tk = token(s);
			default:
			}
			if( tk != TPOpen ) unexpected(tk);
			var args = new Array();
			tk = token(s);
			if( tk != TPClose ) {
				while( true ) {
					switch( tk ) {
					case TId(id): args.push(id);
					default: unexpected(tk);
					}
					tk = token(s);
					switch( tk ) {
					case TComma:
					case TPClose: break;
					default: unexpected(tk);
					}
					tk = token(s);
				}
			}
			EFunction(args,parseExpr(s),name);
		case "return":
			var tk = token(s);
			tokens.add(tk);
			EReturn(if( tk == TSemicolon ) null else parseExpr(s));
		case "new":
			var a = new Array();
			var tk = token(s);
			switch( tk ) {
			case TId(id): a.push(id);
			default: unexpected(tk);
			}
			while( true ) {
				tk = token(s);
				switch( tk ) {
				case TDot:
					tk = token(s);
					switch(tk) {
					case TId(id): a.push(id);
					default: unexpected(tk);
					}
				case TPOpen:
					break;
				default:
					unexpected(tk);
				}
			}
			ENew(a.join("."),parseExprList(s,TPClose));
		case "throw":
			EThrow( parseExpr(s) );
		case "try":
			var e = parseExpr(s);
			var tk = token(s);
			if( !Type.enumEq(tk,TId("catch")) ) unexpected(tk);
			tk = token(s);
			if( tk != TPOpen ) unexpected(tk);
			tk = token(s);
			var vname = switch( tk ) {
			case TId(id): id;
			default: unexpected(tk);
			}
			tk = token(s);
			if( tk != TDoubleDot ) unexpected(tk);
			tk = token(s);
			if( !Type.enumEq(tk,TId("Dynamic")) ) unexpected(tk);
			tk = token(s);
			if( tk != TPClose ) unexpected(tk);
			ETry(e,vname,parseExpr(s));
		default:
			null;
		}
	}

	function parseExprNext( s : haxe.io.Input, e1 : Expr ) {
		var tk = token(s);
		switch( tk ) {
		case TOp(op):
			for( x in unopsSuffix )
				if( x == op ) {
					if( isBlock(e1) || switch(e1) { case EParent(_): true; default: false; } ) {
						tokens.add(tk);
						return e1;
					}
					return parseExprNext(s,EUnop(op,false,e1));
				}
			return makeBinop(op,e1,parseExpr(s));
		case TDot:
			tk = token(s);
			var field = null;
			switch(tk) {
			case TId(id): field = id;
			default: unexpected(tk);
			}
			return parseExprNext(s,EField(e1,field));
		case TPOpen:
			return parseExprNext(s,ECall(e1,parseExprList(s,TPClose)));
		case TBkOpen:
			var e2 = parseExpr(s);
			tk = token(s);
			if( tk != TBkClose ) unexpected(tk);
			return parseExprNext(s,EArray(e1,e2));
		case TQuestion:
			var e2 = parseExpr(s);
			tk = token(s);
			if( tk != TDoubleDot ) unexpected(tk);
			var e3 = parseExpr(s);
			return EIf(e1,e2,e3);
		default:
			tokens.add(tk);
			return e1;
		}
	}

	function parseExprList( s : haxe.io.Input, etk ) {
		var args = new Array();
		var tk = token(s);
		if( tk == etk )
			return args;
		tokens.add(tk);
		while( true ) {
			args.push(parseExpr(s));
			tk = token(s);
			switch( tk ) {
			case TComma:
			default:
				if( tk == etk ) break;
				unexpected(tk);
			}
		}
		return args;
	}

	function readChar( s : haxe.io.Input ) {
		return try s.readByte() catch( e : Dynamic ) 0;
	}

	function readString( s : haxe.io.Input, until ) {
		var c;
		var b = new StringBuf();
		var esc = false;
		var old = line;
		while( true ) {
			try {
				c = s.readByte();
			} catch( e : Dynamic ) {
				line = old;
				throw Error.EUnterminatedString;
			}
			if( esc ) {
				esc = false;
				switch( c ) {
				case 110: b.addChar(10); // \n
				case 114: b.addChar(13); // \r
				case 116: b.addChar(9); // \t
				case 39: b.addChar(39); // \'
				case 34: b.addChar(34); // \"
				case 92: b.addChar(92); // \\
				default: throw Error.EInvalidChar(c);
				}
			} else if( c == 92 )
				esc = true;
			else if( c == until )
				break;
			else {
				if( c == 10 ) line++;
				b.addChar(c);
			}
		}
		return b.toString();
	}

	function token( s : haxe.io.Input ) {
		if( !tokens.isEmpty() )
			return tokens.pop();
		var char;
		if( this.char == null )
			char = readChar(s);
		else {
			char = this.char;
			this.char = null;
		}
		while( true ) {
			switch( char ) {
			case 0: return TEof;
			case 32,9,13: // space, tab, CR
			case 10: line++; // LF
			case 48,49,50,51,52,53,54,55,56,57: // 0...9
				var n = char - 48;
				var exp = 0;
				while( true ) {
					char = readChar(s);
					exp *= 10;
					switch( char ) {
					case 48,49,50,51,52,53,54,55,56,57:
						n = n * 10 + (char - 48);
					case 46:
						if( exp > 0 ) {
							// in case of '...'
							if( exp == 10 && readChar(s) == 46 ) {
								tokens.add(TOp("..."));
								return TConst( CInt(n) );
							}
							throw Error.EInvalidChar(char);
						}
						exp = 1;
					case 120: // x
						if( n > 0 || exp > 0 )
							throw Error.EInvalidChar(char);
						// read hexa
						var n = haxe.Int32.ofInt(0);
						while( true ) {
							char = readChar(s);
							switch( char ) {
							case 48,49,50,51,52,53,54,55,56,57: // 0-9
								n = haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 48));
							case 65,66,67,68,69,70: // A-F
								n = haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 55));
							case 97,98,99,100,101,102: // a-f
								n = haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 87));
							default:
								this.char = char;
								// we allow to parse hexadecimal Int32 in Neko, but when the value will be
								// evaluated by Interpreter, a failure will occur if no Int32 operation is
								// performed
								var v = try CInt(haxe.Int32.toInt(n)) catch( e : Dynamic ) CInt32(n);
								return TConst(v);
							}
						}
					default:
						this.char = char;
						return TConst( (exp > 0) ? CFloat(n * 10 / exp) : CInt(n) );
					}
				}
			case 59: return TSemicolon;
			case 40: return TPOpen;
			case 41: return TPClose;
			case 44: return TComma;
			case 46:
				char = readChar(s);
				switch( char ) {
				case 48,49,50,51,52,53,54,55,56,57:
					var n = char - 48;
					var exp = 1;
					while( true ) {
						char = readChar(s);
						exp *= 10;
						switch( char ) {
						case 48,49,50,51,52,53,54,55,56,57:
							n = n * 10 + (char - 48);
						default:
							this.char = char;
							return TConst( CFloat(n/exp) );
						}
					}
				case 46:
					char = readChar(s);
					if( char != 46 )
						throw Error.EInvalidChar(char);
					return TOp("...");
				default:
					this.char = char;
					return TDot;
				}
			case 123: return TBrOpen;
			case 125: return TBrClose;
			case 91: return TBkOpen;
			case 93: return TBkClose;
			case 39: return TConst( CString(readString(s,39)) );
			case 34: return TConst( CString(readString(s,34)) );
			case 63: return TQuestion;
			case 58: return TDoubleDot;
			default:
				if( ops[char] ) {
					var op = String.fromCharCode(char);
					while( true ) {
						char = readChar(s);
						if( !ops[char] ) {
							if( op.charCodeAt(0) == 47 )
								return tokenComment(s,op,char);
							this.char = char;
							return TOp(op);
						}
						op += String.fromCharCode(char);
					}
				}
				if( idents[char] ) {
					var id = String.fromCharCode(char);
					while( true ) {
						char = readChar(s);
						if( !idents[char] ) {
							this.char = char;
							return TId(id);
						}
						id += String.fromCharCode(char);
					}
				}
				throw Error.EInvalidChar(char);
			}
			char = readChar(s);
		}
		return null;
	}

	function tokenComment( s : haxe.io.Input, op : String, char : Int ) {
		var c = op.charCodeAt(1);
		if( c == 47 ) { // comment
			try {
				while( char != 10 && char != 13 )
					char = s.readByte();
				this.char = char;
			} catch( e : Dynamic ) {
			}
			return token(s);
		}
		if( c == 42 ) { /* comment */
			var old = line;
			try {
				while( true ) {
					while( char != 42 ) {
						if( char == 10 ) line++;
						char = s.readByte();
					}
					char = s.readByte();
					if( char == 47 )
						break;
				}
			} catch( e : Dynamic ) {
				line = old;
				throw Error.EUnterminatedComment;
			}
			return token(s);
		}
		this.char = char;
		return TOp(op);
	}

	function constString( c ) {
		return switch(c) {
		case CInt(v): Std.string(v);
		case CInt32(v): Std.string(v);
		case CFloat(f): Std.string(f);
		case CString(s): s; // TODO : escape + quote
		}
	}

	function tokenString( t ) {
		return switch( t ) {
		case TEof: "<eof>";
		case TConst(c): constString(c);
		case TId(s): s;
		case TOp(s): s;
		case TPOpen: "(";
		case TPClose: ")";
		case TBrOpen: "{";
		case TBrClose: "}";
		case TDot: ".";
		case TComma: ",";
		case TSemicolon: ";";
		case TBkOpen: "[";
		case TBkClose: "]";
		case TQuestion: "?";
		case TDoubleDot: ":";
		}
	}

}
